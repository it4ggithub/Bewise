pageextension 67100 "Aged Acc. Receivable List Ext" extends "Aged Accounts Receivable List"
{

    layout
    {
        addafter(PaymentMethod)
        {
            field("Insurance Category"; Rec."Insurance Category")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Insurance Category', ELL = 'Κατηγορία Ασφάλισης';
            }
        }
    }

    actions
    {
        modify(GenData)
        {
            trigger OnAfterAction()
            begin
                AddExtraCustomerEntries();
                RemoveExcludedCustomerEntries();
                CurrPage.Update(false);
            end;
        }
    }

    trigger OnAfterGetRecord()
    var
        Cust: Record Customer;
        CPHelpTable: Record "CP Help Table";
    begin
        Rec."Insurance Category" := '';
        if Cust.Get(Rec.code26) then begin
            CPHelpTable.SetRange("Field ID", Cust."Insurance Category");
            if CPHelpTable.FindFirst() then
                Rec."Insurance Category" := CPHelpTable."Field DESCR";
        end;
    end;

    local procedure AddExtraCustomerEntries()
    var
        NextEntryNo: Integer;
    begin
        NextEntryNo := GetNextEntryNo();

        InsertExtraCustomerEntry(NextEntryNo, 'C0000097');
        InsertExtraCustomerEntry(NextEntryNo, 'E-100-000426');
        InsertExtraCustomerEntry(NextEntryNo, 'R-703-000005');
    end;

    local procedure InsertExtraCustomerEntry(var NextEntryNo: Integer; CustomerNo: Code[20])
    var
        Customer: Record Customer;
        AsOfDate: Date;
    begin
        Rec.SetRange(code26, CustomerNo);
        Rec.SetRange(Sortkey1, '');
        if not Rec.IsEmpty() then begin
            Rec.SetRange(code26);
            Rec.SetRange(Sortkey1);
            exit;
        end;
        Rec.SetRange(code26);
        Rec.SetRange(Sortkey1);

        Rec.Init();
        Rec.EntryNo := NextEntryNo;
        Rec.code26 := CustomerNo;
        Rec.Sortkey1 := '';
        AsOfDate := DMY2Date(31, 12, 2025);

        if Customer.Get(CustomerNo) then begin
            Rec.Text4 := Customer.Name;
            PopulateExtraEntryFields(Customer, AsOfDate);
        end;

        Rec.Insert(true);
        NextEntryNo += 1;
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        Rec.SetCurrentKey(EntryNo);
        if Rec.FindLast() then
            exit(Rec.EntryNo + 1);

        exit(1);
    end;

    local procedure RemoveExcludedCustomerEntries()
    var
        Customer: Record Customer;
        EntriesToDelete: List of [Integer];
        EntryNoToDelete: Integer;
    begin
        Rec.SetRange(code26);
        if Rec.FindSet() then
            repeat
                if (Rec.code26 <> '') and Customer.Get(Rec.code26) then
                    if IsExcludedCustomerPostingGroup(Customer."Customer Posting Group") then
                        EntriesToDelete.Add(Rec.EntryNo);
            until Rec.Next() = 0;

        foreach EntryNoToDelete in EntriesToDelete do
            if Rec.Get(EntryNoToDelete) then
                Rec.Delete();
    end;

    local procedure PopulateExtraEntryFields(Customer: Record Customer; AsOfDate: Date)
    var
        PaymentTerms: Record "Payment Terms";
        PaymentTermsCode: Code[10];
    begin
        Rec.code22 := Customer."VAT Registration No.";
        Rec.Dec23 := Customer."Official Credit Limit";
        Rec."Insurance Category" := GetInsuranceCategoryDescription(Customer."Insurance Category");
        Rec.code11 := GetCoverPercentage(Customer."Insurance Category", Customer."Country/Region Code");

        PaymentTermsCode := Customer."Payment Terms Code";
        Rec.code10 := PaymentTermsCode;
        if (PaymentTermsCode <> '') and PaymentTerms.Get(PaymentTermsCode) then
            Rec.Text10 := PaymentTerms.Description
        else
            Rec.Text10 := '';

        Rec.Date3 := GetLatestInvoicePostingDate(Customer."No.", AsOfDate);
        Rec.Date4 := GetLatestPaymentPostingDate(Customer."No.", AsOfDate);
        Rec.Dec28 := GetPaymentAmount(Customer."No.", AsOfDate);
        Rec.Dec05 := GetOpenChequesAmount(Customer."No.", AsOfDate);
    end;

    local procedure GetInsuranceCategoryDescription(InsuranceCategoryCode: Code[20]): Text[80]
    var
        CPHelpTable: Record "CP Help Table";
    begin
        if InsuranceCategoryCode = '' then
            exit('');

        CPHelpTable.SetRange("Field ID", InsuranceCategoryCode);
        if CPHelpTable.FindFirst() then
            exit(CPHelpTable."Field DESCR");

        exit('');
    end;

    local procedure GetCoverPercentage(InsuranceCategory: Code[20]; CountryCode: Code[10]): Code[10]
    begin
        if InsuranceCategory = '07' then
            exit('90%');

        if InsuranceCategory = '08' then begin
            if (CountryCode = 'GR') or (CountryCode = 'CYP') then
                exit('90%');

            exit('85%');
        end;

        exit('');
    end;

    local procedure GetLatestInvoicePostingDate(CustomerNo: Code[20]; AsOfDate: Date): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MaxPostingDate: Date;
    begin
        MaxPostingDate := 0D;

        CustLedgerEntry.SetLoadFields("Customer No.", "Posting Date", "Document Type");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);

        if CustLedgerEntry.FindSet() then
            repeat
                if MaxPostingDate < CustLedgerEntry."Posting Date" then
                    MaxPostingDate := CustLedgerEntry."Posting Date";
            until CustLedgerEntry.Next() = 0;

        exit(MaxPostingDate);
    end;

    local procedure GetLatestPaymentPostingDate(CustomerNo: Code[20]; AsOfDate: Date): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MaxPostingDate: Date;
    begin
        MaxPostingDate := 0D;

        CustLedgerEntry.SetLoadFields("Customer No.", "Posting Date", "Document Type");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLedgerEntry.SetFilter("Document Type", '%1|%2|%3',
            CustLedgerEntry."Document Type"::Payment,
            CustLedgerEntry."Document Type"::Refund,
            CustLedgerEntry."Document Type"::" ");

        if CustLedgerEntry.FindSet() then
            repeat
                if MaxPostingDate < CustLedgerEntry."Posting Date" then
                    MaxPostingDate := CustLedgerEntry."Posting Date";
            until CustLedgerEntry.Next() = 0;

        exit(MaxPostingDate);
    end;

    local procedure GetPaymentAmount(CustomerNo: Code[20]; AsOfDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        CustLedgerEntry.SetLoadFields("Customer No.", "Posting Date", "Document Type", Amount);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLedgerEntry.SetFilter("Document Type", '%1|%2|%3',
            CustLedgerEntry."Document Type"::Payment,
            CustLedgerEntry."Document Type"::Refund,
            CustLedgerEntry."Document Type"::" ");

        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.CalcFields(Amount);
                TotalAmount += CustLedgerEntry.Amount;
            until CustLedgerEntry.Next() = 0;

        exit(TotalAmount);
    end;

    local procedure GetOpenChequesAmount(CustomerNo: Code[20]; AsOfDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        CustLedgerEntry.SetLoadFields("Entry No.", "Customer No.", "Posting Date", "Document Type", Open);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
            CustLedgerEntry."Document Type"::Payment,
            CustLedgerEntry."Document Type"::Refund);
        CustLedgerEntry.SetRange(Open, true);

        if CustLedgerEntry.FindSet() then
            repeat
                TotalAmount += SumDetailedAmountForEntry(CustLedgerEntry."Entry No.", AsOfDate);
            until CustLedgerEntry.Next() = 0;

        exit(TotalAmount);
    end;

    local procedure SumDetailedAmountForEntry(CustLedgerEntryNo: Integer; AsOfDate: Date): Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        DetailedCustLedgEntry.SetLoadFields("Cust. Ledger Entry No.", "Posting Date", Amount);
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntryNo);
        DetailedCustLedgEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        if DetailedCustLedgEntry.FindSet() then
            repeat
                TotalAmount += DetailedCustLedgEntry.Amount;
            until DetailedCustLedgEntry.Next() = 0;

        exit(TotalAmount);
    end;

    local procedure IsExcludedCustomerPostingGroup(CustomerPostingGroup: Code[20]): Boolean
    begin
        case CustomerPostingGroup of
            'ΑΥΤΟΠΑΡΑΔΟ',
            'ΜΕΤΑΒΑΤΙΚ1',
            'ΜΕΤΑΒΑΤΙΚ2',
            'ΜΕΤΑΒΑΤΙΚ3',
            'ΜΕΤΑΒΑΤΙΚ4':
                exit(true);
        end;

        exit(false);
    end;
}
