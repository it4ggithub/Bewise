report 67101 "Warehouse Trial Balance Fast"
{
    ApplicationArea = All;
    Caption = 'Warehouse Trial Balance Fast Test BW';

    UsageCategory = ReportsAndAnalysis;
    dataset
    {

        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(Name; Name) { }
            column(Profession; "Profession RCGRBASE") { }
            column(Address; Address) { }
            column(City; City) { }
            column(Post_Code; "Post Code") { }
            column(VAT_Registration_No_; "VAT Registration No.") { }
            column(Tax_Office; "Tax Office RCGRBASE") { }
            column(Picture; Picture) { }
            column(StartDate; StartDate) { }
            column(EndDate; EndDate) { }
            column(LocationFilter; LocationFilter) { }
            column(GlobalDim1Filter; GlobalDim1Filter) { }
            column(GlobalDim2Filter; GlobalDim2Filter) { }
            trigger OnPreDataItem()
            begin
                "Company Information".ReadIsolation := IsolationLevel::ReadUncommitted;
            end;

            trigger OnAfterGetRecord()
            begin
                LocationFilter := GetFilter("Location Code");
                // GlobalDim1Filter := GetFilter("Global Dimension 1 Code");
                // GlobalDim2Filter := GetFilter("Global Dimension 2 Code");
            end;

        }
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Inventory Posting Group";

            column(No_; "No.") { }
            column(Description; Description) { }
            column(Inventory_Posting_Group; "Inventory Posting Group") { }
            column(Item_Category_Code; "Item Category Code") { }
            column(itemAA; ItemCounter) { }

            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Posting Date");

                RequestFilterFields = "Location Code";
                column(HasValueEntry; HasValueEntry) { }
                column(PostingDate; "Posting Date")
                {
                }
                column(ItemLedgerEntryType; "Item Ledger Entry Type")
                {
                }
                column(ItemNo; "Item No.")
                {
                }
                column(InvoicedQuantity; "Invoiced Quantity")
                {
                }
                column(ItemLedgerEntryQuantity; "Item Ledger Entry Quantity")
                {
                }
                column(LocationCode; "Location Code")
                {
                }
                column(GlobalDimension1Code; "Global Dimension 1 Code")
                {
                }
                column(GlobalDimension2Code; "Global Dimension 2 Code")
                {
                }
                column(GenProdPostingGroup; "Gen. Prod. Posting Group")
                {
                }
                column(ExternalDocumentNo; "External Document No.")
                {
                }
                column(SourceNo; "Source No.")
                {
                }
                column(SourcePostingGroup; "Source Posting Group")
                {
                }

                column(Amount_from_purch; Amount_from_purch) { }
                column(Amount_from_purch_exp; Amount_from_purch_exp) { }
                column(Amount_from_sale; Amount_from_sale) { }
                column(Amount_from_sale_exp; Amount_from_sale_exp) { }
                column(Cost_from_sale; Cost_from_sale) { }
                column(Cost_from_sale_exp; Cost_from_sale_exp) { }
                column(Amount_from_cons; Amount_from_cons) { }
                column(Amount_from_prod; Amount_from_prod) { }
                column(Amount_from_other_neg; Amount_from_other_neg) { }
                column(Amount_from_other_pos; Amount_from_other_pos) { }
                column(Quantity_from_purch; Quantity_from_purch) { }
                column(Quantity_from_purch_exp; Quantity_from_purch_exp) { }
                column(Quantity_from_sale; Quantity_from_sale) { }
                column(Quantity_from_sale_exp; Quantity_from_sale_exp) { }
                column(Quantity_from_prod; Quantity_from_prod) { }
                column(Quantity_from_cons; Quantity_from_cons) { }
                column(Quantity_from_census; Quantity_from_census) { }
                column(Quantity_from_other_pos; Quantity_from_other_pos) { }
                column(Quantity_from_other_neg; Quantity_from_other_neg) { }
                column(countN; countN) { }
                column(Quantity_from_transfer; Quantity_from_transfer) { }
                column(Quantity_from_transfer_exp; Quantity_from_transfer_exp) { }
                column(Amount_from_transfer; Amount_from_transfer) { }
                column(Amount_from_census; Amount_from_census) { }
                column(Quantity_from_prev_period; Quantity_from_prev_period) { }
                column(Amount_from_prev_period; Amount_from_prev_period) { }
                column(Quantity_from_self; Quantity_from_self) { }
                column(Amount_from_self; Amount_from_self) { }
                column(Document_No_; "Document No.") { }
                column(Document_Type; "Document Type") { }
                column(Tm_Name; Name) { }
                column(UnitOfMeas; UnitOfMeas) { }
                column(Reason_Code; "Reason Code") { }
                column(costfromYL; costfromYL) { }
                column(costfromER; costfromER) { }
                column(costfromGBE; costfromGBE) { }
                column(totalcost; totalcost) { }

                trigger OnPreDataItem()
                begin
                    ValueEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
                    SetRange("Posting Date", 0D, EndDate);
                end;

                trigger OnAfterGetRecord()
                var
                    Vendors: Record Vendor;
                    Customers: Record Customer;
                begin
                    Clear(Quantity_from_transfer);
                    Clear(Amount_from_transfer);
                    Clear(Quantity_from_transfer_exp);
                    Clear(Quantity_from_prev_period);
                    Clear(Amount_from_prev_period);

                    // Logic for populating transfer-related values based on posting date
                    if StartDate <> 0D then begin
                        // ek metaforas kanonika
                        if ("Posting Date" < StartDate) then begin
                            if "Item Ledger Entry Quantity" = 0 then begin
                                Quantity_from_transfer := "Invoiced Quantity";
                                Quantity_from_transfer_exp := -"Invoiced Quantity";
                            end else if "Invoiced Quantity" <> 0 then begin
                                Quantity_from_transfer := "Invoiced Quantity";
                            end else begin
                                Quantity_from_transfer_exp := "Item Ledger Entry Quantity";
                            end;
                            Amount_from_transfer := "Cost Amount (Actual)";

                            if "Item Ledger Entry Quantity" = 0 then begin
                                Quantity_from_purch := "Invoiced Quantity";
                                Quantity_from_purch_exp := -"Invoiced Quantity";
                            end else if "Invoiced Quantity" <> 0 then begin
                                Quantity_from_purch := "Invoiced Quantity";
                            end else begin
                                Quantity_from_purch_exp := "Item Ledger Entry Quantity";
                            end;
                            Amount_from_purch := "Cost Amount (Actual)";
                        end;

                        if "Posting Date" >= StartDate then
                            countN := countN + 1;
                    end else
                        countN := countN + 1;

                    Clear(Quantity_from_purch);
                    Clear(Quantity_from_purch_exp);
                    Clear(Quantity_from_sale);
                    Clear(Quantity_from_sale_exp);
                    Clear(Quantity_from_prod);
                    Clear(Amount_from_prod);
                    Clear(Quantity_from_cons);
                    Clear(Amount_from_cons);
                    Clear(Quantity_from_census);
                    Clear(Amount_from_census);
                    Clear(Quantity_from_other_pos);
                    Clear(Quantity_from_other_neg);
                    Clear(Amount_from_other_pos);
                    Clear(Amount_from_other_neg);
                    Clear(Amount_from_purch);
                    Clear(Amount_from_purch_exp);
                    Clear(Amount_from_sale);
                    Clear(Amount_from_sale_exp);
                    Clear(Cost_from_sale);
                    Clear(Cost_from_sale_exp);
                    Clear(costfromYL);
                    Clear(costfromER);
                    Clear(costfromGBE);
                    Clear(totalcost);

                    if HasPreviousPeriodWindow then
                        if ("Posting Date" >= PrevPeriodStartDate) and ("Posting Date" <= PrevPeriodEndDate) and ("Document No." <> 'ΕΓΓΡΑΦΈΣ ΑΠΟΓΡΑΦΉΣ') and ("Document No." <> 'ΕΓΓΡΑΦΕΣ ΑΠΟΓΡΑΦΗΣ') and (COPYSTR("Document No.", 1, 3) <> 'ΑΠ.') then begin
                            Quantity_from_prev_period := "Item Ledger Entry Quantity";
                            Amount_from_prev_period := "Cost Amount (Actual)";
                        end;

                    if (("Document No." = 'ΕΓΓΡΑΦΈΣ ΑΠΟΓΡΑΦΉΣ') or ("Document No." = 'ΕΓΓΡΑΦΕΣ ΑΠΟΓΡΑΦΗΣ') or (COPYSTR("Document No.", 1, 3) = 'ΑΠ.')) and ((StartDate = 0D) or ("Posting Date" < StartDate)) then begin
                        Quantity_from_census := "Item Ledger Entry Quantity";
                        Amount_from_census := "Cost Amount (Actual)";
                    end else
                        if "Posting Date" >= StartDate then begin
                            case "Item Ledger Entry Type" of
                                "Item Ledger Entry Type"::Purchase:
                                    begin
                                        if "Item Ledger Entry Quantity" = 0 then begin
                                            Quantity_from_purch := "Invoiced Quantity";
                                            Quantity_from_purch_exp := -"Invoiced Quantity";
                                        end else if "Invoiced Quantity" <> 0 then begin
                                            Quantity_from_purch := "Invoiced Quantity";
                                        end else begin
                                            Quantity_from_purch_exp := "Item Ledger Entry Quantity";
                                        end;

                                        Amount_from_purch := "Purchase Amount (Actual)";
                                        Amount_from_purch_exp := "Purchase Amount (Expected)";
                                    end;
                                "Item Ledger Entry Type"::Sale:
                                    begin
                                        if "Item Ledger Entry Quantity" = 0 then begin
                                            Quantity_from_sale := "Invoiced Quantity";
                                            Quantity_from_sale_exp := -"Invoiced Quantity";
                                        end else if "Invoiced Quantity" <> 0 then begin
                                            Quantity_from_sale := "Invoiced Quantity";
                                        end else begin
                                            Quantity_from_sale_exp := "Item Ledger Entry Quantity";
                                        end;

                                        Amount_from_sale := "Sales Amount (Actual)";
                                        Amount_from_sale_exp := "Sales Amount (Expected)";
                                        Cost_from_sale := "Cost Amount (Actual)";
                                        Cost_from_sale_exp := "Cost Amount (Expected)";
                                    end;
                                "Item Ledger Entry Type"::Output:
                                    begin
                                        Quantity_from_prod := "Item Ledger Entry Quantity";
                                        Amount_from_prod := "Cost Amount (Actual)";
                                        costfromYL := "Cost Component 1 RCGRBASE";
                                        costfromER := "Cost Component 3 RCGRBASE";
                                        costfromGBE := "Cost Component 2 RCGRBASE";
                                        totalcost := costfromYL + costfromER + costfromGBE;
                                    end;
                                "Item Ledger Entry Type"::" ":
                                    begin
                                        Clear(costfromYL);
                                        Clear(costfromER);
                                        Clear(costfromGBE);
                                        Clear(totalcost);
                                    end;
                                "Item Ledger Entry Type"::Consumption:
                                    begin
                                        if "Cost Component 2 RCGRBASE" <> 0 then begin
                                            Quantity_from_prod := "Item Ledger Entry Quantity";
                                            Amount_from_prod := "Cost Amount (Actual)";
                                            costfromYL := "Cost Component 1 RCGRBASE";
                                            costfromER := "Cost Component 3 RCGRBASE";
                                            costfromGBE := "Cost Component 2 RCGRBASE";
                                            totalcost := costfromYL + costfromER + costfromGBE;
                                        end else begin
                                            Quantity_from_cons := "Item Ledger Entry Quantity";
                                            Amount_from_cons := "Cost Amount (Actual)";
                                        end;
                                    end;
                                else begin
                                    if "Item Ledger Entry Quantity" > 0 then
                                        Quantity_from_other_pos := "Item Ledger Entry Quantity"
                                    else
                                        Quantity_from_other_neg := "Item Ledger Entry Quantity";

                                    if "Cost Amount (Actual)" > 0 then
                                        Amount_from_other_pos := "Cost Amount (Actual)"
                                    else
                                        Amount_from_other_neg := "Cost Amount (Actual)";
                                end;
                            end;
                        end;

                    if UseValuationCostForProduction and ((Quantity_from_census <> 0) or (Quantity_from_prod <> 0)) then
                        ApplyValuationCostAdjustments("Item No.", "Location Code", "Variant Code");

                    case "Source Type" of
                        "Source Type"::Customer:
                            begin
                                if Customers.Get("Source No.") then
                                    Name := Customers.Name;
                            end;
                        "Source Type"::Vendor:
                            begin
                                if Vendors.Get("Source No.") then
                                    Name := Vendors.Name;
                            end;
                        else
                            Name := '';
                    end;
                end;
            }

            trigger OnPreDataItem()
            begin
                Item.ReadIsolation := IsolationLevel::ReadUncommitted;
                ItemCounter := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                ItemCounter := ItemCounter + 1;
                UnitOfMeas := "Base Unit of Measure";
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
                group("Date Filter")
                {
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                    }
                }
                group("Options")
                {
                    field(UseValuationCostForProduction; UseValuationCostForProduction)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Valuation Cost Adjustments';
                        ToolTip = 'When enabled, census amounts are recalculated from Valuation Cost RCGRBASE and production cost components are read from valuation cost. Other amount fields continue to come from the Value Entry table.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            UseValuationCostForProduction := true;
        end;

    }

    trigger OnPreReport()
    begin
        HasPreviousPeriodWindow := (StartDate <> 0D) and (Date2DMY(StartDate, 2) > 1);
        if HasPreviousPeriodWindow then begin
            PrevPeriodStartDate := DMY2Date(1, 1, Date2DMY(StartDate, 3));
            PrevPeriodEndDate := CalcDate('<-1D>', DMY2Date(1, Date2DMY(StartDate, 2), Date2DMY(StartDate, 3)));
        end;
    end;

    var
        StartDate: Date;
        EndDate: Date;
        Quantity_from_transfer: Decimal;
        Quantity_from_transfer_exp: Decimal;
        Quantity_from_prev_period: Decimal;
        Quantity_from_purch: Decimal;
        Quantity_from_purch_exp: Decimal;
        Quantity_from_cons: Decimal;
        Quantity_from_census: Decimal;
        Quantity_from_prod: Decimal;
        Quantity_from_sale: Decimal;
        Quantity_from_sale_exp: Decimal;
        Quantity_from_self: Decimal;
        Quantity_from_other_pos: Decimal;
        Quantity_from_other_neg: Decimal;
        Amount_from_transfer: Decimal;
        Amount_from_prev_period: Decimal;
        Amount_from_purch: Decimal;
        Amount_from_purch_exp: Decimal;
        Amount_from_cons: Decimal;
        Amount_from_census: Decimal;
        Amount_from_prod: Decimal;
        Amount_from_sale: Decimal;
        Amount_from_sale_exp: Decimal;
        Amount_from_self: Decimal;
        Amount_from_other_pos: Decimal;
        Amount_from_other_neg: Decimal;
        Cost_from_AYlik: Decimal;
        Cost_from_AErg: Decimal;
        Cost_from_GBE: Decimal;
        Cost_from_sale: Decimal;
        Cost_from_sale_exp: Decimal;
        countN: Integer;
        Name: Text[100];
        ItemCounter: Integer;
        UnitOfMeas: Code[20];
        LocationFilter: Text[100];
        GlobalDim1Filter: Text[100];
        GlobalDim2Filter: Text[100];
        HideItemsWithoutValueEntries: Boolean;
        HasValueEntry: Boolean;
        zoneCode: Code[10];
        costfromYL: Decimal;
        costfromER: Decimal;
        costfromGBE: Decimal;
        totalcost: Decimal;
        UseValuationCostForProduction: Boolean;
        PrevPeriodStartDate: Date;
        PrevPeriodEndDate: Date;
        HasPreviousPeriodWindow: Boolean;

    local procedure ApplyValuationCostAdjustments(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10])
    var
        ValuationCost: Record "Valuation Cost RCGRBASE";
        ValuationUnitCost: Decimal;
        ValComp1: Decimal;
        ValComp2: Decimal;
        ValComp3: Decimal;
        ValComp4: Decimal;
    begin
        if not FindValuationCost(ItemNo, LocationCode, VariantCode, ValuationCost) then
            exit;

        ValuationUnitCost := ValuationCost."Valuation Cost per Unit";
        ValComp1 := ValuationCost."Cost Component 1";
        ValComp2 := ValuationCost."Cost Component 2";
        ValComp3 := ValuationCost."Cost Component 3";
        ValComp4 := ValuationCost."Cost Component 4";

        if Quantity_from_census <> 0 then
            Amount_from_census := Round(Quantity_from_census * ValuationUnitCost, 0.01);

        if Quantity_from_prod <> 0 then begin
            costfromYL := ValComp1;
            costfromER := ValComp2;
            costfromGBE := ValComp4;
            totalcost := ValComp1 + ValComp2 + ValComp3 + ValComp4;
        end;
    end;

    local procedure FindValuationCost(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; var ValuationCost: Record "Valuation Cost RCGRBASE"): Boolean
    begin
        ValuationCost.Reset();
        ValuationCost.SetRange("Item No.", ItemNo);

        ValuationCost.SetRange("Location Code", LocationCode);
        ValuationCost.SetRange("Variant Code", VariantCode);
        if ValuationCost.FindFirst() then
            exit(true);

        ValuationCost.SetRange("Variant Code");
        if ValuationCost.FindFirst() then
            exit(true);

        ValuationCost.SetRange("Location Code");
        if ValuationCost.FindFirst() then
            exit(true);

        exit(false);
    end;
}
