tableextension 67100 "Sort Table RCGRBASE Ext" extends "Sort Table RCGRBASE"
{
    fields
    {
        field(67100; "Insurance Category"; Text[80])
        {
            CaptionML = ENU = 'Insurance Category', ELL = 'Κατηγορία Ασφάλισης';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    trigger OnAfterInsert()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        AsOfDate: Date;
        InvoiceAmount: Decimal;
        CreditAmount: Decimal;
        Amount: Decimal;
        RelatedAmount: Decimal;
    begin
        if (Rec.Code26 <> '') and Customer.Get(Rec.Code26) then begin
            Rec.Bool1 := Customer.Insured;
            if IsExcludedCustomerPostingGroup(Customer."Customer Posting Group") then begin
                Rec.Delete();
                exit;
            end;
        end;

        AsOfDate := DMY2Date(31, 12, 2025);

        // Recalculate Dec01-Dec04 like the original page logic, without Ship-to Code filter.
        InvoiceAmount := 0;
        CreditAmount := 0;
        Amount := 0;
        RelatedAmount := 0;

        CustLEntry.Reset();
        CustLEntry.SetLoadFields("Entry No.", "Customer No.", "Posting Date", "Document Type");
        CustLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLEntry.SetRange("Customer No.", Rec.Code26);
        if CustLEntry.FindSet() then
            repeat
                Amount += SumDetailedAmountForEntry(CustLEntry."Entry No.", AsOfDate);
            until CustLEntry.Next() = 0;

        CustLEntry.SetRange("Document Type", CustLEntry."Document Type"::Invoice);
        if CustLEntry.FindSet() then
            repeat
                InvoiceAmount += SumDetailedAmountForEntry(CustLEntry."Entry No.", AsOfDate);
            until CustLEntry.Next() = 0;

        CustLEntry.SetRange("Document Type", CustLEntry."Document Type"::"Credit Memo");
        if CustLEntry.FindSet() then
            repeat
                CreditAmount += SumDetailedAmountForEntry(CustLEntry."Entry No.", AsOfDate);
            until CustLEntry.Next() = 0;

        CustLEntry.Reset();
        CustLEntry.SetLoadFields("Entry No.", "Customer No.", "Posting Date", "Document Type", Open);
        CustLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        CustLEntry.SetRange("Customer No.", Rec.Code26);
        CustLEntry.SetRange(Open, true);
        if CustLEntry.FindSet() then
            repeat
                RelatedAmount += SumDetailedAmountForEntry(CustLEntry."Entry No.", AsOfDate);
            until CustLEntry.Next() = 0;

        Rec.Dec01 := InvoiceAmount;
        Rec.Dec02 := CreditAmount;
        Rec.Dec03 := RelatedAmount;
        Rec.Dec04 := Amount;

        // Calculate the Open Payments (ΑΝΟΙΧΤΕΣ ΠΛΗΡΩΜΕΣ-ΠΙΣΤΩΤΙΚΑ) based on whether there is a negative balance (Dec04 - ΥΠΟΛΟΙΠΟ)
        // If there is a negative balance, then the Open Payments (Dec13) will be equal to the negative balance (Dec04)
        // In addition, the Day subtotals (Υποσύνολα ημερών) should be set to 0 if the balance is negative
        Rec.Dec13 := 0;
        if Rec.Dec04 < 0 then begin
            Rec.Dec13 := Rec.Dec04;

            // Dec06 = 0-90
            Rec.Dec06 := 0;
            // Dec07 = 91-180
            Rec.Dec07 := 0;
            // Dec08 = 181-270
            Rec.Dec08 := 0;
            // Dec09 = 271-360
            Rec.Dec09 := 0;
            // Dec10 = 361-450
            Rec.Dec10 := 0;
            // Dec11 = 451+
            Rec.Dec11 := 0;
            // Dec12 = Total
            Rec.Dec12 := 0;
        end

        // If the balance is 0, then all should be 0
        else if Rec.Dec04 = 0 then begin
            Rec.Dec06 := 0;
            Rec.Dec07 := 0;
            Rec.Dec08 := 0;
            Rec.Dec09 := 0;
            Rec.Dec10 := 0;
            Rec.Dec11 := 0;
            Rec.Dec12 := 0;
            Rec.Dec13 := 0;
        end
        else begin

            Rec.Dec06 := 0;
            Rec.Dec07 := 0;
            Rec.Dec08 := 0;
            Rec.Dec09 := 0;
            Rec.Dec10 := 0;
            Rec.Dec11 := 0;

            CustLedgerEntry.Reset();
            CustLedgerEntry.SetLoadFields("Entry No.", "Posting Date", "Customer No.", "Document Type");
            CustLedgerEntry.SetRange("Customer No.", Rec.Code26);
            // CustLedgerEntry.SetRange("Ship-to Code", Rec.Sortkey1);

            // Same aging filters as Aged AR logic, using Cust. Ledger Entry amount.
            CustLedgerEntry.SetRange("Posting Date", AsOfDate - 90, AsOfDate);
            Rec.Dec06 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            CustLedgerEntry.SetRange("Posting Date", AsOfDate - 180, AsOfDate - 91);
            Rec.Dec07 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            CustLedgerEntry.SetRange("Posting Date", AsOfDate - 270, AsOfDate - 181);
            Rec.Dec08 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            CustLedgerEntry.SetRange("Posting Date", AsOfDate - 360, AsOfDate - 271);
            Rec.Dec09 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            CustLedgerEntry.SetRange("Posting Date", AsOfDate - 450, AsOfDate - 361);
            Rec.Dec10 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            CustLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate - 451);
            Rec.Dec11 := SumCustLedgerAmount(CustLedgerEntry, AsOfDate);

            if Rec.Dec06 < 0 then begin
                Rec.Dec13 += Rec.Dec06;
                Rec.Dec06 := 0;
            end;
            if Rec.Dec07 < 0 then begin
                Rec.Dec13 += Rec.Dec07;
                Rec.Dec07 := 0;
            end;
            if Rec.Dec08 < 0 then begin
                Rec.Dec13 += Rec.Dec08;
                Rec.Dec08 := 0;
            end;
            if Rec.Dec09 < 0 then begin
                Rec.Dec13 += Rec.Dec09;
                Rec.Dec09 := 0;
            end;
            if Rec.Dec10 < 0 then begin
                Rec.Dec13 += Rec.Dec10;
                Rec.Dec10 := 0;
            end;
            if Rec.Dec11 < 0 then begin
                Rec.Dec13 += Rec.Dec11;
                Rec.Dec11 := 0;
            end;

            Rec.Dec12 := Rec.Dec06 + Rec.Dec07 + Rec.Dec08 + Rec.Dec09 + Rec.Dec10 + Rec.Dec11;
        end;

        // Calculate the total. It should be equal to either the total of the Day subtotals (Dec12) or the Open Payments (Dec13)
        // And since it's either one or the other (one of them should always be 0), we can just add them together to get the total
        Rec.Dec14 := Rec.Dec12 + Rec.Dec13;

        Rec.Modify();
    end;

    local procedure SumCustLedgerAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; AsOfDate: Date): Decimal
    var
        CustLedgerAmount: Decimal;
    begin
        CustLedgerAmount := 0;

        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerAmount += SumDetailedAmountForEntry(CustLedgerEntry."Entry No.", AsOfDate);
            until CustLedgerEntry.Next() = 0;

        exit(CustLedgerAmount);
    end;

    local procedure IsExcludedCustomerPostingGroup(CustomerPostingGroup: Code[20]): Boolean
    begin
        case CustomerPostingGroup of
            'ΑΥΤΟΠΑΡΑΔΟΤΟ',
            'ΜΕΤΑΒΑΤΙΚ1',
            'ΜΕΤΑΒΑΤΙΚ2',
            'ΜΕΤΑΒΑΤΙΚ3',
            'ΜΕΤΑΒΑΤΙΚ4':
                exit(true);
        end;

        exit(false);
    end;

    local procedure SumDetailedAmountForEntry(CustLedgerEntryNo: Integer; AsOfDate: Date): Decimal
    var
        DetLedgerEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedAmount: Decimal;
    begin
        DetailedAmount := 0;

        DetLedgerEntry.Reset();
        DetLedgerEntry.SetLoadFields("Cust. Ledger Entry No.", "Posting Date", Amount);
        DetLedgerEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntryNo);
        DetLedgerEntry.SetFilter("Posting Date", '..%1', AsOfDate);
        if DetLedgerEntry.FindSet() then
            repeat
                DetailedAmount += DetLedgerEntry.Amount;
            until DetLedgerEntry.Next() = 0;

        exit(DetailedAmount);
    end;
}
