report 67101 "Intra-Group Entries"
{
    ApplicationArea = All;
    Caption = 'Intercompany Entries';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = 'TestedLayouts/IntraGroupEntries.rdlc';

    dataset
    {
        // Single data item over the temporary buffer: it holds either the customer or the
        // vendor ledger entries, together with the company info ReadCompanyInfo() read once.
        dataitem(IntraGroupEntry; "Intra-Group Ledg. Entry")
        {
            // Insertion order: entries in ledger order, lines in document line order.
            DataItemTableView = sorting("Sequence No.");

            // Company info of the company the report runs in.
            column(CompanyName; CompanyInfoName) { }
            column(CompanyVATRegNo; CompanyInfoVATRegNo) { }
            column(CompanyTaxOffice; CompanyInfoTaxOffice) { }
            column(CompanyAddress; CompanyInfoAddress) { }
            column(CompanyCity; CompanyInfoCity) { }
            column(CompanyPostCode; CompanyInfoPostCode) { }
            column(CompanyAddressFull; CompanyInfoAddressFull) { }
            column(CompanyProfession; CompanyInfoProfession) { }
            // Request page period, echoed so the layout can print it. Blank means no limit.
            column(StartDate; StartDate) { }
            column(EndDate; EndDate) { }

            // Entry columns, filled from the selected customer's or vendor's ledger entries.
            column(AccountNo; "Account No.") { }
            column(AccountName; "Account Name") { }
            column(LedgerEntryNo; "Entry No.") { }
            column(PostingDate; "Posting Date") { }
            column(TransactionType; "Document Type") { }
            column(DocumentNo; "Document No.") { }
            column(DocumentDate; "Document Date") { }
            column(ExternalDocumentNo; "External Document No.") { }
            column(CurrencyCode; "Currency Code") { }
            column(Amount; Amount) { }
            column(AmountLCY; "Amount (LCY)") { }
            column(OriginalAmount; "Original Amount") { }
            column(RemainingAmount; "Remaining Amount") { }
            column(IsOpen; "Open") { }
            column(DueDate; "Due Date") { }
            column(LineType; "Line Type") { }
            column(LineDescription; "Line Description") { }
            column(InventoryPostingGroup; "Inventory Posting Group") { }
            column(ItemType; "Item Type") { }

            trigger OnPreDataItem()
            begin
                // The buffer is filled through this data item's own record variable, so the
                // rows inserted here are exactly the rows the data item iterates.
                BuildBuffer(IntraGroupEntry);
                IntraGroupEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(CustomerGroup)
                {
                    Caption = 'Customer';

                    field(CustomerNo; CustomerNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        TableRelation = Customer;
                        ToolTip = 'Specifies the customer whose ledger entries are listed. Leave the vendor fields empty.';

                        trigger OnValidate()
                        begin
                            if CustomerNo <> '' then
                                CustomerVATNo := '';
                        end;
                    }
                    field(CustomerVATNo; CustomerVATNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer VAT No.';
                        ToolTip = 'Specifies the customer by VAT registration number instead of by customer number.';

                        trigger OnValidate()
                        begin
                            if CustomerVATNo <> '' then
                                CustomerNo := '';
                        end;
                    }
                }
                group(VendorGroup)
                {
                    Caption = 'Vendor';

                    field(VendorNo; VendorNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        TableRelation = Vendor;
                        ToolTip = 'Specifies the vendor whose ledger entries are listed. Leave the customer fields empty.';

                        trigger OnValidate()
                        begin
                            if VendorNo <> '' then
                                VendorVATNo := '';
                        end;
                    }
                    field(VendorVATNo; VendorVATNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor VAT No.';
                        ToolTip = 'Specifies the vendor by VAT registration number instead of by vendor number.';

                        trigger OnValidate()
                        begin
                            if VendorVATNo <> '' then
                                VendorNo := '';
                        end;
                    }
                }
                group(DateGroup)
                {
                    Caption = 'Date Filter';

                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the first posting date to include. Leave blank to include entries from the beginning.';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the last posting date to include. Leave blank to include entries up to the end.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        ResolveSelections();
        ReadCompanyInfo();
    end;

    var
        CustomerNo: Code[20];
        CustomerVATNo: Text[20];
        VendorNo: Code[20];
        VendorVATNo: Text[20];
        StartDate: Date;
        EndDate: Date;
        // Company info of the company the report runs in. Read once by ReadCompanyInfo(),
        // then emitted on every row.
        CompanyInfoName: Text[150];
        CompanyInfoVATRegNo: Text[50];
        CompanyInfoTaxOffice: Text[50];
        CompanyInfoAddress: Text[150];
        CompanyInfoCity: Text[50];
        CompanyInfoPostCode: Text[20];
        CompanyInfoAddressFull: Text[150];
        CompanyInfoProfession: Text[150];
        // Account numbers actually used by the branches. When a VAT number is used, these
        // hold the account numbers found by the lookup.
        ResolvedCustomerNo: Code[20];
        ResolvedVendorNo: Code[20];
        // Set by ResolveSelections(): true when the filled-in selection is a vendor.
        UseVendor: Boolean;
        // Counter that keeps every buffer row unique: a single ledger entry can now produce
        // several rows, one per document line.
        BufferSequenceNo: Integer;
        NoAccountErr: Label 'Fill in a customer or a vendor.';
        BothAccountsErr: Label 'Fill in either a customer or a vendor, not both.';
        CustomerNotFoundErr: Label 'Customer %1 does not exist.';
        VendorNotFoundErr: Label 'Vendor %1 does not exist.';
        CustomerVATNotFoundErr: Label 'No customer has VAT registration number %1.';
        CustomerVATAmbiguousErr: Label 'More than one customer has VAT registration number %1.';
        VendorVATNotFoundErr: Label 'No vendor has VAT registration number %1.';
        VendorVATAmbiguousErr: Label 'More than one vendor has VAT registration number %1.';
        NoEntriesErr: Label 'No ledger entries were found for %1 in the selected period.';

    // Works from whichever side is filled in: customer fields, or vendor fields. Filling in
    // both is an error. When a VAT number is given it wins over the account number.
    local procedure ResolveSelections()
    var
        CustLookup: Record Customer;
        VendLookup: Record Vendor;
        CustomerFilled: Boolean;
        VendorFilled: Boolean;
    begin
        ResolvedCustomerNo := '';
        ResolvedVendorNo := '';
        UseVendor := false;

        CustomerFilled := (CustomerNo <> '') or (CustomerVATNo <> '');
        VendorFilled := (VendorNo <> '') or (VendorVATNo <> '');
        if CustomerFilled and VendorFilled then
            Error(BothAccountsErr);
        if not CustomerFilled and not VendorFilled then
            Error(NoAccountErr);

        if VendorFilled then begin
            UseVendor := true;
            if VendorVATNo <> '' then begin
                VendLookup.Reset();
                VendLookup.SetRange("VAT Registration No.", VendorVATNo);
                if not VendLookup.FindFirst() then
                    Error(VendorVATNotFoundErr, VendorVATNo);
                if VendLookup.Next() > 0 then
                    Error(VendorVATAmbiguousErr, VendorVATNo);
                ResolvedVendorNo := VendLookup."No.";
                exit;
            end;
            if not VendLookup.Get(VendorNo) then
                Error(VendorNotFoundErr, VendorNo);
            ResolvedVendorNo := VendorNo;
            exit;
        end;

        if CustomerVATNo <> '' then begin
            CustLookup.Reset();
            CustLookup.SetRange("VAT Registration No.", CustomerVATNo);
            if not CustLookup.FindFirst() then
                Error(CustomerVATNotFoundErr, CustomerVATNo);
            if CustLookup.Next() > 0 then
                Error(CustomerVATAmbiguousErr, CustomerVATNo);
            ResolvedCustomerNo := CustLookup."No.";
            exit;
        end;

        if not CustLookup.Get(CustomerNo) then
            Error(CustomerNotFoundErr, CustomerNo);
        ResolvedCustomerNo := CustomerNo;
    end;

    // Blank request dates mean "no limit" on that side.
    local procedure EffectiveStartDate(): Date
    begin
        if StartDate = 0D then
            exit(19000101D);
        exit(StartDate);
    end;

    local procedure EffectiveEndDate(): Date
    begin
        if EndDate = 0D then
            exit(99991231D);
        exit(EndDate);
    end;

    // Reads the company information of the company the report runs in, once, so every row
    // can carry it. "Company Information" holds one record per company of the database, so
    // the current company has to be matched by name; CompanyProperty.DisplayName() is the
    // display name that is stored in the Name field (CompanyName() returns the short name).
    local procedure ReadCompanyInfo()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Reset();
        CompanyInfo.SetRange(Name, CompanyProperty.DisplayName());
        if not CompanyInfo.FindFirst() then begin
            CompanyInfo.Reset();
            CompanyInfo.SetRange(Name, CompanyName());
            if not CompanyInfo.FindFirst() then
                exit;
        end;
        CompanyInfoName := CompanyInfo.Name;
        CompanyInfoVATRegNo := CompanyInfo."VAT Registration No.";
        CompanyInfoTaxOffice := CompanyInfo."Tax Office RCGRBASE";
        CompanyInfoAddress := CompanyInfo.Address;
        CompanyInfoCity := CompanyInfo.City;
        CompanyInfoPostCode := CompanyInfo."Post Code";
        CompanyInfoProfession := CompanyInfo."Profession RCGRBASE";
        CompanyInfoAddressFull := CombineAddress(CompanyInfoAddress, CompanyInfoPostCode, CompanyInfoCity);
    end;

    // 'Address, Post Code City' - only the parts that are filled in are combined.
    local procedure CombineAddress(Address: Text[150]; PostCode: Text[20]; City: Text[50]): Text[150]
    var
        Combined: Text[150];
    begin
        if Address <> '' then
            Combined := Address;
        if PostCode <> '' then begin
            if Combined <> '' then
                Combined += ', ';
            Combined += PostCode;
        end;
        if City <> '' then begin
            if Combined <> '' then
                Combined += ' ';
            Combined += City;
        end;
        exit(Combined);
    end;

    // Fills the temporary buffer with one row per ledger entry of the selected customer
    // or vendor. The document lines are summarized into the two text columns.
    local procedure BuildBuffer(var Buffer: Record "Intra-Group Ledg. Entry")
    begin
        Buffer.DeleteAll();
        BufferSequenceNo := 0;
        if UseVendor then
            InsertVendorEntries(Buffer)
        else
            InsertCustomerEntries(Buffer);
        if not Buffer.FindFirst() then
            Error(NoEntriesErr, SelectedAccountNo());
    end;

    // Inserts the row that was just built in Buffer. A ledger entry can produce several rows
    // (one per document line), so the key of the buffer is a sequence number rather than the
    // entry number - otherwise the second line of the same entry collides.
    local procedure InsertBufferRow(var Buffer: Record "Intra-Group Ledg. Entry")
    begin
        BufferSequenceNo += 1;
        Buffer."Sequence No." := BufferSequenceNo;
        Buffer.Insert();
    end;

    local procedure SelectedAccountNo(): Code[20]
    begin
        if UseVendor then
            exit(ResolvedVendorNo);
        exit(ResolvedCustomerNo);
    end;

    local procedure InsertCustomerEntries(var Buffer: Record "Intra-Group Ledg. Entry")
    var
        CustLookup: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not CustLookup.Get(ResolvedCustomerNo) then
            exit;
        CustLedgerEntry.SetRange("Customer No.", ResolvedCustomerNo);
        // Blank request dates mean that no date limit is applied.
        CustLedgerEntry.SetRange("Posting Date", EffectiveStartDate(), EffectiveEndDate());
        if not CustLedgerEntry.FindSet() then
            exit;
        repeat
            // 'Original Amount' is a FlowField on the ledger entry, so it has to be
            // calculated explicitly - otherwise it reads as 0.
            CustLedgerEntry.CalcFields("Original Amount");
            // Payments and refunds are filtered out of the report.
            if not IsExcludedDocumentType(CustLedgerEntry."Document Type") then begin
                if HasDocumentLines(CustLedgerEntry."Document Type") then
                    // Invoices and credit memos are printed line by line, so the ledger entry
                    // itself does not produce a (totals) row.
                    InsertCustomerDocLines(Buffer, CustLedgerEntry, CustLookup)
                else begin
                    Buffer.Init();
                    FillBufferFromCustEntry(Buffer, CustLedgerEntry);
                    Buffer."Account No." := CustLookup."No.";
                    Buffer."Account Name" := CustLookup.Name;
                    InsertBufferRow(Buffer);
                end;
            end;
        until CustLedgerEntry.Next() = 0;
    end;

    // One buffer row per posted sales document line. Comment and blank lines are skipped,
    // and each line's own type/amount drives the Line Type and Original Amount columns.
    // Posted credit memos are NOT in Sales Invoice Line: they have their own table
    // ("Sales Cr.Memo Line" - note there is no space after "Cr."), so read them from there.
    local procedure InsertCustomerDocLines(var Buffer: Record "Intra-Group Ledg. Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry"; CustLookup: Record Customer)
    var
        SalesLine: Record "Sales Invoice Line";
        SalesCmLine: Record "Sales Cr.Memo Line";
    begin
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::"Credit Memo" then begin
            SalesCmLine.SetRange("Document No.", CustLedgerEntry."Document No.");
            if not SalesCmLine.FindSet() then
                exit;
            repeat
                // Comment/filler lines carry no number, so requiring a No. skips them.
                if SalesCmLine."No." <> '' then
                    AddCustomerLine(Buffer, CustLedgerEntry, CustLookup, Format(SalesCmLine."Type"), SalesCmLine."No.", SalesCmLine.Description, SalesCmLine."Type" = SalesCmLine."Type"::Item, SalesCmLine.Amount);
            until SalesCmLine.Next() = 0;
        end else begin
            SalesLine.SetRange("Document No.", CustLedgerEntry."Document No.");
            if not SalesLine.FindSet() then
                exit;
            repeat
                // Comment/filler lines carry no number, so requiring a No. skips them.
                if SalesLine."No." <> '' then
                    AddCustomerLine(Buffer, CustLedgerEntry, CustLookup, Format(SalesLine."Type"), SalesLine."No.", SalesLine.Description, SalesLine."Type" = SalesLine."Type"::Item, SalesLine.Amount);
            until SalesLine.Next() = 0;
        end;
    end;

    // Builds and stores one row for a sales document line.
    local procedure AddCustomerLine(var Buffer: Record "Intra-Group Ledg. Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry"; CustLookup: Record Customer; LineTypeText: Text[50]; LineNo: Code[20]; LineDescription: Text[100]; IsItem: Boolean; LineAmount: Decimal)
    begin
        Buffer.Init();
        FillBufferFromCustEntry(Buffer, CustLedgerEntry);
        Buffer."Account No." := CustLookup."No.";
        Buffer."Account Name" := CustLookup.Name;
        Buffer."Line Type" := LineTypeText;
        Buffer."Line Description" := LineDescription;
        // Credit memo lines are printed with a negative amount.
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::"Credit Memo" then
            Buffer."Original Amount" := -Abs(LineAmount)
        else
            Buffer."Original Amount" := LineAmount;
        if IsItem then
            FillItemFields(Buffer, LineNo);
        InsertBufferRow(Buffer);
    end;

    local procedure FillBufferFromCustEntry(var Buffer: Record "Intra-Group Ledg. Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        // Assigned field by field on purpose: TransferFields matches by field number, not
        // by name, so it copies nothing between these two different tables.
        Buffer."Entry No." := CustLedgerEntry."Entry No.";
        Buffer."Posting Date" := CustLedgerEntry."Posting Date";
        Buffer."Document Type" := CustLedgerEntry."Document Type";
        Buffer."Document No." := CustLedgerEntry."Document No.";
        Buffer."Document Date" := CustLedgerEntry."Document Date";
        Buffer."External Document No." := CustLedgerEntry."External Document No.";
        Buffer."Currency Code" := CustLedgerEntry."Currency Code";
        Buffer.Amount := CustLedgerEntry.Amount;
        Buffer."Amount (LCY)" := CustLedgerEntry."Amount (LCY)";
        Buffer."Original Amount" := CustLedgerEntry."Original Amount";
        Buffer."Remaining Amount" := CustLedgerEntry."Remaining Amount";
        Buffer.Open := CustLedgerEntry.Open;
        Buffer."Due Date" := CustLedgerEntry."Due Date";
    end;

    local procedure InsertVendorEntries(var Buffer: Record "Intra-Group Ledg. Entry")
    var
        VendLookup: Record Vendor;
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if not VendLookup.Get(ResolvedVendorNo) then
            exit;
        VendLedgerEntry.SetRange("Vendor No.", ResolvedVendorNo);
        // Blank request dates mean that no date limit is applied.
        VendLedgerEntry.SetRange("Posting Date", EffectiveStartDate(), EffectiveEndDate());
        if not VendLedgerEntry.FindSet() then
            exit;
        repeat
            // 'Original Amount' is a FlowField on the ledger entry, so it has to be
            // calculated explicitly - otherwise it reads as 0.
            VendLedgerEntry.CalcFields("Original Amount");
            // Payments and refunds are filtered out of the report.
            if not IsExcludedDocumentType(VendLedgerEntry."Document Type") then begin
                if HasDocumentLines(VendLedgerEntry."Document Type") then
                    // Invoices and credit memos are printed line by line, so the ledger entry
                    // itself does not produce a (totals) row.
                    InsertVendorDocLines(Buffer, VendLedgerEntry, VendLookup)
                else begin
                    Buffer.Init();
                    FillBufferFromVendEntry(Buffer, VendLedgerEntry);
                    Buffer."Account No." := VendLookup."No.";
                    Buffer."Account Name" := VendLookup.Name;
                    InsertBufferRow(Buffer);
                end;
            end;
        until VendLedgerEntry.Next() = 0;
    end;

    // One buffer row per posted purchase document line. Comment and blank lines are skipped,
    // and each line's own type/amount drives the Line Type and Original Amount columns.
    // Posted purchase credit memos are NOT in Purch. Inv. Line: they have their own tables
    // (Purch. Cr. Memo Hdr./Line), so the lines have to be read from there.
    local procedure InsertVendorDocLines(var Buffer: Record "Intra-Group Ledg. Entry"; var VendLedgerEntry: Record "Vendor Ledger Entry"; VendLookup: Record Vendor)
    var
        PurchaseLine: Record "Purch. Inv. Line";
        PurchaseCmLine: Record "Purch. Cr. Memo Line";
    begin
        if VendLedgerEntry."Document Type" = VendLedgerEntry."Document Type"::"Credit Memo" then begin
            PurchaseCmLine.SetRange("Document No.", VendLedgerEntry."Document No.");
            if not PurchaseCmLine.FindSet() then
                exit;
            repeat
                // Comment/filler lines carry no number, so requiring a No. skips them.
                if PurchaseCmLine."No." <> '' then
                    AddVendorLine(Buffer, VendLedgerEntry, VendLookup, Format(PurchaseCmLine."Type"), PurchaseCmLine."No.", PurchaseCmLine.Description, PurchaseCmLine."Type" = PurchaseCmLine."Type"::Item, PurchaseCmLine.Amount);
            until PurchaseCmLine.Next() = 0;
        end else begin
            PurchaseLine.SetRange("Document No.", VendLedgerEntry."Document No.");
            if not PurchaseLine.FindSet() then
                exit;
            repeat
                // Comment/filler lines carry no number, so requiring a No. skips them.
                if PurchaseLine."No." <> '' then
                    AddVendorLine(Buffer, VendLedgerEntry, VendLookup, Format(PurchaseLine."Type"), PurchaseLine."No.", PurchaseLine.Description, PurchaseLine."Type" = PurchaseLine."Type"::Item, PurchaseLine.Amount);
            until PurchaseLine.Next() = 0;
        end;
    end;

    // Builds and stores one row for a purchase document line.
    local procedure AddVendorLine(var Buffer: Record "Intra-Group Ledg. Entry"; var VendLedgerEntry: Record "Vendor Ledger Entry"; VendLookup: Record Vendor; LineTypeText: Text[50]; LineNo: Code[20]; LineDescription: Text[100]; IsItem: Boolean; LineAmount: Decimal)
    begin
        Buffer.Init();
        FillBufferFromVendEntry(Buffer, VendLedgerEntry);
        Buffer."Account No." := VendLookup."No.";
        Buffer."Account Name" := VendLookup.Name;
        Buffer."Line Type" := LineTypeText;
        Buffer."Line Description" := LineDescription;
        // Vendor invoices are printed positive, vendor credit memos negative.
        if VendLedgerEntry."Document Type" = VendLedgerEntry."Document Type"::"Credit Memo" then
            Buffer."Original Amount" := -Abs(LineAmount)
        else
            Buffer."Original Amount" := Abs(LineAmount);
        if IsItem then
            FillItemFields(Buffer, LineNo);
        InsertBufferRow(Buffer);
    end;

    local procedure FillBufferFromVendEntry(var Buffer: Record "Intra-Group Ledg. Entry"; var VendLedgerEntry: Record "Vendor Ledger Entry")
    begin
        // Assigned field by field on purpose: TransferFields matches by field number, not
        // by name, so it copies nothing between these two different tables.
        Buffer."Entry No." := VendLedgerEntry."Entry No.";
        Buffer."Posting Date" := VendLedgerEntry."Posting Date";
        Buffer."Document Type" := VendLedgerEntry."Document Type";
        Buffer."Document No." := VendLedgerEntry."Document No.";
        Buffer."Document Date" := VendLedgerEntry."Document Date";
        Buffer."External Document No." := VendLedgerEntry."External Document No.";
        Buffer."Currency Code" := VendLedgerEntry."Currency Code";
        Buffer.Amount := VendLedgerEntry.Amount;
        Buffer."Amount (LCY)" := VendLedgerEntry."Amount (LCY)";
        Buffer."Original Amount" := VendLedgerEntry."Original Amount";
        Buffer."Remaining Amount" := VendLedgerEntry."Remaining Amount";
        Buffer.Open := VendLedgerEntry.Open;
        Buffer."Due Date" := VendLedgerEntry."Due Date";
    end;

    // Invoices and credit memos are the documents that are printed line by line.
    local procedure HasDocumentLines(DocumentType: Enum "Gen. Journal Document Type"): Boolean
    begin
        exit((DocumentType = DocumentType::Invoice) or (DocumentType = DocumentType::"Credit Memo"));
    end;

    // Payments, refunds and entries without a document type are left out of the report.
    local procedure IsExcludedDocumentType(DocumentType: Enum "Gen. Journal Document Type"): Boolean
    begin
        exit((DocumentType = DocumentType::" ") or (DocumentType = DocumentType::Payment) or (DocumentType = DocumentType::Refund));
    end;

    // Item lines carry the item's inventory posting group (the Ο.Κ. column) and its type.
    local procedure FillItemFields(var Buffer: Record "Intra-Group Ledg. Entry"; ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit;
        Buffer."Inventory Posting Group" := Item."Inventory Posting Group";
        Buffer."Item Type" := Format(Item."Type");
    end;
}
