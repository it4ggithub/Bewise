report 67103 "Warehouse TB Optimized"
{
    ApplicationArea = All;
    Caption = 'Warehouse Trial Balance BW';

    DefaultLayout = RDLC;
    RDLCLayout = 'TestedLayouts/VivlioApothikisOptimized.rdlc';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {

        // Company header data is emitted once and reused by the RDLC layout.
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
                // This report is read-only, so lower isolation helps reduce blocking.
                "Company Information".ReadIsolation := IsolationLevel::ReadUncommitted;
            end;

            trigger OnAfterGetRecord()
            begin
                // Echo the active request filters so the layout can print them.
                LocationFilter := GetFilter("Location Code");
                // GlobalDim1Filter := GetFilter("Global Dimension 1 Code");
                // GlobalDim2Filter := GetFilter("Global Dimension 2 Code");
            end;

        }

        // The report iterates items first so the layout stays grouped by item.
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Inventory Posting Group";

            column(No_; "No.") { }
            column(Description; Description) { }
            column(Inventory_Posting_Group; "Inventory Posting Group") { }
            column(Item_Category_Code; "Item Category Code") { }
            column(ESIL_Only_Value; "ESIL Only Value") { }
            // column(Item_Category_1; "Item Category 1") { }
            // column(Item_Category_2; "Item Category 2") { }
            // column(Item_Category_3; "Item Category 3") { }
            // column(Item_Category_4; "Item Category 4") { }
            // column(Item_Category_5; "Item Category 5") { }


            column(itemAA; ItemCounter) { }
            //added this data item to incoporate the zone code


            // Value entries are the main fact source for quantities and amounts.
            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Posting Date");

                RequestFilterFields = "Location Code";

                // Filter records based on the start date
                trigger OnPreDataItem()

                begin
                    // Read with low isolation and restrict the scan to the requested end date.
                    ValueEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
                    if StartDate <> 0D then begin
                        SetRange("Posting Date", 0D, EndDate);
                    end

                    else begin
                        SetRange("Posting Date", 0D, EndDate);
                    end;
                end;

                // After fetching the record, populate additional fields based on item and location
                trigger OnAfterGetRecord()

                var
                    Vendors: Record Vendor;
                    Customers: Record Customer;
                    PrevPeriodStartDate: Date;
                    PrevPeriodEndDate: Date;
                    IsCensusEntry: Boolean;
                    IsEsilOnlyValue: Boolean;
                    SourceNameCacheKey: Text[30];
                    CachedSourceName: Text[100];
                    ValuationCacheKey: Text[50];
                    ValuationCostForEndDate: Record "Valuation Cost RCGRBASE";
                    HasStockAndCost: Boolean;

                begin

                    if HideZeroEndValues then begin
                        if not HideZeroLocationCache.Get("Location Code", HasStockAndCost) then begin
                            HasStockAndCost := LocationHasStockAndValuationRecord("Item No.", "Location Code");
                            HideZeroLocationCache.Add("Location Code", HasStockAndCost);
                        end;
                        if not HasStockAndCost then begin
                            CurrReport.Skip();
                            exit;
                        end;
                    end;

                    DisplayInvoicedQuantity := "Invoiced Quantity";
                    DisplayItemLedgerEntryQuantity := "Item Ledger Entry Quantity";

                    Clear(ValuationCostPerUnit);
                    if HasEndDateValuationPeriod then begin
                        ValuationCacheKey := StrSubstNo('%1:%2:%3', StrLen("Location Code"), "Location Code", "Variant Code");
                        if not EndDateValuationCostCache.Get(ValuationCacheKey, ValuationCostPerUnit) then begin
                            if FindValuationCostForPeriod("Item No.", "Location Code", "Variant Code", EndDateValuationPeriodCode, ValuationCostForEndDate) then
                                ValuationCostPerUnit := ValuationCostForEndDate."Valuation Cost per Unit";
                            EndDateValuationCostCache.Add(ValuationCacheKey, ValuationCostPerUnit);
                        end;
                    end;

                    UnitOfMeas := Item."Base Unit of Measure";
                    Clear(IsEsilOnlyValue);
                    IsEsilOnlyValue := Item."ESIL Only Value";

                    //Get zone code


                    // Reset transfer and previous-period buckets before classifying the row.
                    Clear(Quantity_from_transfer);
                    Clear(Amount_from_transfer);
                    Clear(Quantity_from_transfer_exp);
                    Clear(Quantity_from_prev_period);
                    Clear(Amount_from_prev_period);

                    // Transfer-like entries before the requested period are treated as opening movements.
                    if StartDate <> 0D then begin
                        // ek metaforas kanonika
                        if ("Posting Date" < StartDate) then begin
                            // Quantity_from_transfer := "Invoiced Quantity";
                            // Quantity_from_transfer_exp := "Item Ledger Entry Quantity";
                            if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
                                Quantity_from_transfer := "Item Ledger Entry Quantity";
                                Quantity_from_transfer_exp := -"Item Ledger Entry Quantity";
                            end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
                                Quantity_from_transfer := "Item Ledger Entry Quantity";
                            end else begin
                                Quantity_from_transfer_exp := "Item Ledger Entry Quantity"; // here are receipts
                            end;
                            Amount_from_transfer := "Cost Amount (Actual)";
                            // Also add transfer entries to purchase fields
                            if "Item Ledger Entry Quantity" = 0 then begin
                                Quantity_from_purch := "Item Ledger Entry Quantity";
                                Quantity_from_purch_exp := -"Item Ledger Entry Quantity";
                            end else if "Invoiced Quantity" <> 0 then begin
                                Quantity_from_purch := "Item Ledger Entry Quantity";
                            end else begin
                                Quantity_from_purch_exp := "Item Ledger Entry Quantity";
                            end;
                            Amount_from_purch := "Cost Amount (Actual)";
                        end;

                        if "Posting Date" >= StartDate then begin
                            countN := countN + 1;
                        end;
                    end
                    else begin

                        countN := countN + 1;

                    end;

                    // Clear all movement buckets so only the matching branch fills them.

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
                    clear(Amount_from_sale);
                    clear(Amount_from_sale_exp);
                    clear(Cost_from_sale);
                    clear(Cost_from_sale_exp);
                    Clear(costfromYL);
                    Clear(costfromER);
                    Clear(costfromGBE);
                    Clear(totalcost);

                    // Census rows are now identified only by the requested date rules.
                    IsCensusEntry := IsCensusPostingDateEligible("Posting Date");

                    // Previous-period values are limited to the months before StartDate in the same year.
                    // From November 2025 onward, never pull prior-period movements from before 31/10/2025.
                    if (StartDate <> 0D) and (Date2DMY(StartDate, 2) > 1) then begin
                        PrevPeriodStartDate := DMY2Date(1, 1, Date2DMY(StartDate, 3));
                        if StartDate >= DMY2Date(1, 11, 2025) then
                            if PrevPeriodStartDate < DMY2Date(31, 10, 2025) then
                                PrevPeriodStartDate := DMY2Date(31, 10, 2025);

                        PrevPeriodEndDate := CalcDate('<-1D>', DMY2Date(1, Date2DMY(StartDate, 2), Date2DMY(StartDate, 3)));

                        if ("Posting Date" >= PrevPeriodStartDate) and ("Posting Date" <= PrevPeriodEndDate) and not IsCensusEntry then begin
                            Quantity_from_prev_period := "Item Ledger Entry Quantity";
                            Amount_from_prev_period := "Cost Amount (Actual)";
                        end;
                    end;

                    // Census entries are handled before normal movement classification.

                    if IsCensusEntry then begin
                        Quantity_from_census := "Item Ledger Entry Quantity";
                        Amount_from_census := "Cost Amount (Actual)";
                    end else
                        if "Posting Date" >= StartDate then begin
                            // All non-census movements are mapped into one report bucket by entry type.
                            case "Item Ledger Entry Type" of

                                "Item Ledger Entry Type"::Purchase:
                                    begin
                                        // Purchase rows split invoiced quantity from expected quantity.
                                        // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
                                        // Quantity_from_purch := "Item Ledger Entry Quantity";
                                        if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
                                            Quantity_from_purch := "Item Ledger Entry Quantity";
                                            Quantity_from_purch_exp := -"Item Ledger Entry Quantity";
                                        end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
                                            Quantity_from_purch := "Item Ledger Entry Quantity";
                                        end else begin
                                            Quantity_from_purch := "Item Ledger Entry Quantity";
                                            Quantity_from_purch_exp := "Item Ledger Entry Quantity"; // here are receipts
                                        end;


                                        // Quantity_from_purch := "Invoiced Quantity";
                                        Amount_from_purch := "Purchase Amount (Actual)";
                                        Amount_from_purch_exp := "Purchase Amount (Expected)";

                                    end;

                                "Item Ledger Entry Type"::Sale:
                                    begin
                                        // Sale rows use the same invoiced-versus-expected split as purchases.
                                        // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
                                        //Quantity_from_sale := "Item Ledger Entry Quantity";
                                        if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a shipment
                                            Quantity_from_sale := "Item Ledger Entry Quantity";
                                            Quantity_from_sale_exp := -"Item Ledger Entry Quantity";
                                        end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a shipment
                                            Quantity_from_sale := "Item Ledger Entry Quantity";
                                        end else begin
                                            Quantity_from_sale := "Item Ledger Entry Quantity";
                                            Quantity_from_sale_exp := "Item Ledger Entry Quantity"; // here are Shipments
                                        end;
                                        // Quantity_from_sale := "Invoiced Quantity";
                                        // Quantity_from_sale_exp := "Item Ledger Entry Quantity";
                                        Amount_from_sale := "Sales Amount (Actual)";
                                        Amount_from_sale_exp := "Sales Amount (Expected)";
                                        Cost_from_sale := "Cost Amount (Actual)";
                                        Cost_from_sale_exp := "Cost Amount (Expected)";


                                    end;
                                "Item Ledger Entry Type"::Output:
                                    begin
                                        // Output rows represent production receipts.
                                        Quantity_from_prod := "Item Ledger Entry Quantity";
                                        Amount_from_prod := "Cost Amount (Actual)";
                                        //? cost from ---
                                        costfromYL := "Cost Component 1 RCGRBASE";
                                        costfromER := "Cost Component 3 RCGRBASE";
                                        costfromGBE := "Cost Component 2 RCGRBASE";
                                        totalcost := costfromYL + costfromER + costfromGBE;
                                    end;
                                //??? what do I do with this ?????????????????????
                                "Item Ledger Entry Type"::" ":
                                    begin
                                        // Blank entry type contributes no production cost breakdown.
                                        Clear(costfromYL);
                                        Clear(costfromER);
                                        Clear(costfromGBE);
                                        Clear(totalcost);
                                    end;
                                "Item Ledger Entry Type"::Consumption:
                                    begin
                                        // Consumption with component 2 populated is treated as subproduct output.
                                        if "Cost Component 2 RCGRBASE" <> 0 then begin
                                            // subproduct production
                                            Quantity_from_prod := "Item Ledger Entry Quantity";
                                            Amount_from_prod := "Cost Amount (Actual)";
                                            //? cost from ---
                                            costfromYL := "Cost Component 1 RCGRBASE";
                                            costfromER := "Cost Component 3 RCGRBASE";
                                            costfromGBE := "Cost Component 2 RCGRBASE";
                                            totalcost := costfromYL + costfromER + costfromGBE;
                                        end else begin
                                            Quantity_from_cons := "Item Ledger Entry Quantity";
                                            Amount_from_cons := "Cost Amount (Actual)";
                                        end;
                                        // if "Item Ledger Entry Quantity" < 0 then begin

                                        // end else begin // arnitiki analwsi einai paragwgi
                                        //     Quantity_from_prod := "Item Ledger Entry Quantity";
                                        //     Amount_from_prod := "Cost Amount (Actual)";
                                        //     //? cost from ---
                                        //     costfromYL := "Cost Component 1 RCGRBASE";
                                        //     costfromER := "Cost Component 3 RCGRBASE";
                                        //     costfromGBE := "Cost Component 2 RCGRBASE";
                                        //     totalcost := costfromYL + costfromER + costfromGBE;
                                        // end;

                                    end;

                                else begin
                                    // All remaining entry types fall into generic positive or negative buckets.

                                    if "Item Ledger Entry Quantity" > 0 then begin
                                        Quantity_from_other_pos := "Item Ledger Entry Quantity";
                                    end
                                    else begin
                                        Quantity_from_other_neg := "Item Ledger Entry Quantity";
                                    end;

                                    if "Cost Amount (Actual)" > 0 then begin
                                        Amount_from_other_pos := "Cost Amount (Actual)";
                                    end
                                    else begin
                                        Amount_from_other_neg := "Cost Amount (Actual)";
                                    end;
                                end;
                            end;
                        end;

                    // Optional valuation adjustments only affect census values and production cost breakdown.
                    if UseValuationCostForProduction then
                        ApplyValuationCostAdjustments("Item No.", "Location Code", "Posting Date", "Variant Code");

                    // ESIL-only items keep their amounts but must expose zero quantities everywhere.
                    if IsEsilOnlyValue then
                        ZeroReportQuantities();

                    // Source names are resolved late because they depend on the row source type.
                    case "Source Type" of
                        "Source Type"::Customer:
                            begin
                                SourceNameCacheKey := StrSubstNo('C:%1', "Source No.");
                                if SourceNameCache.Get(SourceNameCacheKey, CachedSourceName) then
                                    Name := CachedSourceName
                                else
                                    if Customers.Get("Source No.") then begin
                                        Name := Customers.Name;
                                        SourceNameCache.Add(SourceNameCacheKey, Name);
                                    end;
                            end;
                        "Source Type"::Vendor:
                            begin
                                SourceNameCacheKey := StrSubstNo('V:%1', "Source No.");
                                if SourceNameCache.Get(SourceNameCacheKey, CachedSourceName) then
                                    Name := CachedSourceName
                                else
                                    if Vendors.Get("Source No.") then begin
                                        Name := Vendors.Name;
                                        SourceNameCache.Add(SourceNameCacheKey, Name);
                                    end;
                            end;


                        else
                            Name := '';

                    end;

                    EndQuantity := Quantity_from_census + Quantity_from_purch + Quantity_from_cons + Quantity_from_prod + Quantity_from_sale - Quantity_from_self + Quantity_from_other_pos + Quantity_from_other_neg;
                    EndValue := EndQuantity * ValuationCostPerUnit;

                    AddCurrentValueEntryToSummary(ValueEntry);
                    CurrReport.Skip();
                end;

            }
            dataitem(SummaryBuffer; "Warehouse TB Summary Buffer")
            {
                UseTemporary = true;
                DataItemTableView = sorting("Item No.", "Location Code", "Source Name");

                column(HasValueEntry; "Has Value Entry") { }
                column(PostingDate; "Posting Date") { }
                column(ItemLedgerEntryType; "Item Ledger Entry Type") { }
                column(ItemNo; "Item No.") { }
                column(InvoicedQuantity; "Invoiced Quantity") { }
                column(ItemLedgerEntryQuantity; "Item Ledger Entry Quantity") { }
                column(LocationCode; "Location Code") { }
                column(GlobalDimension1Code; "Global Dimension 1 Code") { }
                column(GlobalDimension2Code; "Global Dimension 2 Code") { }
                column(GenProdPostingGroup; "Gen. Prod. Posting Group") { }
                column(ExternalDocumentNo; "External Document No.") { }
                column(SourceNo; "Source No.") { }
                column(SourcePostingGroup; "Source Posting Group") { }
                column(Amount_from_purch; "Amount from purch") { }
                column(Amount_from_purch_exp; "Amount from purch exp") { }
                column(Amount_from_sale; "Amount from sale") { }
                column(Amount_from_sale_exp; "Amount from sale exp") { }
                column(Cost_from_sale; "Cost from sale") { }
                column(Cost_from_sale_exp; "Cost from sale exp") { }
                column(Amount_from_cons; "Amount from cons") { }
                column(Amount_from_prod; "Amount from prod") { }
                column(Amount_from_other_neg; "Amount from other neg") { }
                column(Amount_from_other_pos; "Amount from other pos") { }
                column(Quantity_from_purch; "Quantity from purch") { }
                column(Quantity_from_purch_exp; "Quantity from purch exp") { }
                column(Quantity_from_sale; "Quantity from sale") { }
                column(Quantity_from_sale_exp; "Quantity from sale exp") { }
                column(Quantity_from_prod; "Quantity from prod") { }
                column(Quantity_from_cons; "Quantity from cons") { }
                column(Quantity_from_census; "Quantity from census") { }
                column(Quantity_from_other_pos; "Quantity from other pos") { }
                column(Quantity_from_other_neg; "Quantity from other neg") { }
                column(countN; "Count N") { }
                column(Quantity_from_transfer; "Quantity from transfer") { }
                column(Quantity_from_transfer_exp; "Quantity from transfer exp") { }
                column(Amount_from_transfer; "Amount from transfer") { }
                column(Amount_from_census; "Amount from census") { }
                column(Quantity_from_prev_period; "Quantity from prev period") { }
                column(Amount_from_prev_period; "Amount from prev period") { }
                column(Quantity_from_self; "Quantity from self") { }
                column(Amount_from_self; "Amount from self") { }
                column(Document_No_; "Document No.") { }
                column(Document_Type; "Document Type") { }
                column(Tm_Name; "Source Name") { }
                column(UnitOfMeas; "Unit of Measure") { }
                column(Reason_Code; "Reason Code") { }
                column(costfromYL; "Cost from YL") { }
                column(costfromER; "Cost from ER") { }
                column(costfromGBE; "Cost from GBE") { }
                column(totalcost; "Total Cost") { }
                column(ValuationCostPerUnit; "Valuation Cost per Unit") { }
                column(EndQuantity; "End Quantity") { }
                column(EndValue; "End Value") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Item No.", Item."No.");
                end;
            }
            trigger OnPreDataItem()

            begin
                // Read item master data without taking stronger locks than necessary.
                Item.ReadIsolation := IsolationLevel::ReadUncommitted;
                ItemCounter := 0;
                Clear(EndDateValuationPeriodCode);
                Clear(SourceNameCache);
                Clear(HideZeroLocationCache);
                HasEndDateValuationPeriod := false;
                if EndDate <> 0D then
                    HasEndDateValuationPeriod := FindCostingPeriodCode(EndDate, EndDateValuationPeriodCode);
            end;

            trigger OnAfterGetRecord()

            begin

                // Simple running counter used by the layout.
                Clear(EndDateValuationCostCache);
                SummaryBuffer.Reset();
                SummaryBuffer.DeleteAll();
                Clear(HideZeroLocationCache);
                if (CopyStr("No.", 1, 3) = '199') and ("Item Category Code" = 'ΠΡΟΙΟΝΤΑ') then
                    CurrReport.Skip()
                else begin
                    if HideZeroEndValues and (not ItemHasStockAndValuationRecord("No.")) then
                        CurrReport.Skip()
                    else
                        ItemCounter := ItemCounter + 1;
                end;

            end;
        }

    }

    // Request page only controls the reporting period and optional valuation adjustments.
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
                // group("Options")
                group("Options")
                {
                    field(UseValuationCostForProduction; UseValuationCostForProduction)
                    {
                        ApplicationArea = All;
                        // This toggle keeps Value Entry amounts but applies valuation-based census and production adjustments.
                        Caption = 'Use Valuation Cost Adjustments';
                        ToolTip = 'When enabled, census amounts are recalculated from Valuation Cost RCGRBASE and production cost components are read from valuation cost. Other amount fields continue to come from the Value Entry table.';

                    }
                    field(HideZeroEndValues; HideZeroEndValues)
                    {
                        ApplicationArea = All;
                        Caption = 'Hide Items Without Stock';
                        ToolTip = 'When enabled, item and location rows without nonzero ending stock or without a valuation-cost record for the ending date are hidden. A valuation-cost record with a zero unit cost is included.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin

            UseValuationCostForProduction := true;

        end;

    }


    // Report state is stored in globals because the RDLC dataset reads the calculated buckets directly.
    var
        StartDate: Date;
        EndDate: Date;
        // item_description: Text[100];
        // item_logcat: Code[20];
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
        ItemCounter: Integer; // Variable for the item counter to be displayed in ItemAA
        DisplayInvoicedQuantity: Decimal;
        DisplayItemLedgerEntryQuantity: Decimal;
        UnitOfMeas: Code[20];
        loc_des: text[100];
        LocationFilter: Text[100];
        GlobalDim1Filter: Text[100];
        GlobalDim2Filter: Text[100];
        HideItemsWithoutValueEntries: Boolean;
        HasValueEntry: Boolean;
        zoneCode: Code[10]; // variable for Zones
        costfromYL: Decimal;
        costfromER: Decimal;
        costfromGBE: Decimal;
        totalcost: Decimal;
        ValuationCostPerUnit: Decimal;
        EndDateValuationPeriodCode: Text[50];
        HasEndDateValuationPeriod: Boolean;
        EndDateValuationCostCache: Dictionary of [Text, Decimal];
        SourceNameCache: Dictionary of [Text, Text];
        HideZeroLocationCache: Dictionary of [Code[10], Boolean];
        UseValuationCostForProduction: Boolean;
        EndQuantity: Decimal;
        EndValue: Decimal;
        HideZeroEndValues: Boolean;

    local procedure AddCurrentValueEntryToSummary(var CurrentValueEntry: Record "Value Entry")
    begin
        if not SummaryBuffer.Get(CurrentValueEntry."Item No.", CurrentValueEntry."Location Code", Name) then begin
            SummaryBuffer.Init();
            SummaryBuffer."Item No." := CurrentValueEntry."Item No.";
            SummaryBuffer."Location Code" := CurrentValueEntry."Location Code";
            SummaryBuffer."Source Name" := Name;
            SummaryBuffer."Posting Date" := CurrentValueEntry."Posting Date";
            SummaryBuffer."Item Ledger Entry Type" := Format(CurrentValueEntry."Item Ledger Entry Type");
            SummaryBuffer."Has Value Entry" := HasValueEntry;
            SummaryBuffer."Count N" := countN;
            SummaryBuffer."Global Dimension 1 Code" := CurrentValueEntry."Global Dimension 1 Code";
            SummaryBuffer."Global Dimension 2 Code" := CurrentValueEntry."Global Dimension 2 Code";
            SummaryBuffer."Gen. Prod. Posting Group" := CurrentValueEntry."Gen. Prod. Posting Group";
            SummaryBuffer."External Document No." := CurrentValueEntry."External Document No.";
            SummaryBuffer."Source No." := CurrentValueEntry."Source No.";
            SummaryBuffer."Source Posting Group" := CurrentValueEntry."Source Posting Group";
            SummaryBuffer."Document No." := CurrentValueEntry."Document No.";
            SummaryBuffer."Document Type" := Format(CurrentValueEntry."Document Type");
            SummaryBuffer."Unit of Measure" := UnitOfMeas;
            SummaryBuffer."Reason Code" := CurrentValueEntry."Reason Code";
            SummaryBuffer."Valuation Cost per Unit" := ValuationCostPerUnit;
            SummaryBuffer.Insert();
        end;

        SummaryBuffer.Get(CurrentValueEntry."Item No.", CurrentValueEntry."Location Code", Name);
        SummaryBuffer."Invoiced Quantity" := SummaryBuffer."Invoiced Quantity" + DisplayInvoicedQuantity;
        SummaryBuffer."Item Ledger Entry Quantity" := SummaryBuffer."Item Ledger Entry Quantity" + DisplayItemLedgerEntryQuantity;
        SummaryBuffer."Amount from purch" := SummaryBuffer."Amount from purch" + Amount_from_purch;
        SummaryBuffer."Amount from purch exp" := SummaryBuffer."Amount from purch exp" + Amount_from_purch_exp;
        SummaryBuffer."Amount from sale" := SummaryBuffer."Amount from sale" + Amount_from_sale;
        SummaryBuffer."Amount from sale exp" := SummaryBuffer."Amount from sale exp" + Amount_from_sale_exp;
        SummaryBuffer."Cost from sale" := SummaryBuffer."Cost from sale" + Cost_from_sale;
        SummaryBuffer."Cost from sale exp" := SummaryBuffer."Cost from sale exp" + Cost_from_sale_exp;
        SummaryBuffer."Amount from cons" := SummaryBuffer."Amount from cons" + Amount_from_cons;
        SummaryBuffer."Amount from prod" := SummaryBuffer."Amount from prod" + Amount_from_prod;
        SummaryBuffer."Amount from other neg" := SummaryBuffer."Amount from other neg" + Amount_from_other_neg;
        SummaryBuffer."Amount from other pos" := SummaryBuffer."Amount from other pos" + Amount_from_other_pos;
        SummaryBuffer."Quantity from purch" := SummaryBuffer."Quantity from purch" + Quantity_from_purch;
        SummaryBuffer."Quantity from purch exp" := SummaryBuffer."Quantity from purch exp" + Quantity_from_purch_exp;
        SummaryBuffer."Quantity from sale" := SummaryBuffer."Quantity from sale" + Quantity_from_sale;
        SummaryBuffer."Quantity from sale exp" := SummaryBuffer."Quantity from sale exp" + Quantity_from_sale_exp;
        SummaryBuffer."Quantity from prod" := SummaryBuffer."Quantity from prod" + Quantity_from_prod;
        SummaryBuffer."Quantity from cons" := SummaryBuffer."Quantity from cons" + Quantity_from_cons;
        SummaryBuffer."Quantity from census" := SummaryBuffer."Quantity from census" + Quantity_from_census;
        SummaryBuffer."Quantity from other pos" := SummaryBuffer."Quantity from other pos" + Quantity_from_other_pos;
        SummaryBuffer."Quantity from other neg" := SummaryBuffer."Quantity from other neg" + Quantity_from_other_neg;
        SummaryBuffer."Quantity from transfer" := SummaryBuffer."Quantity from transfer" + Quantity_from_transfer;
        SummaryBuffer."Quantity from transfer exp" := SummaryBuffer."Quantity from transfer exp" + Quantity_from_transfer_exp;
        SummaryBuffer."Amount from transfer" := SummaryBuffer."Amount from transfer" + Amount_from_transfer;
        SummaryBuffer."Amount from census" := SummaryBuffer."Amount from census" + Amount_from_census;
        SummaryBuffer."Quantity from prev period" := SummaryBuffer."Quantity from prev period" + Quantity_from_prev_period;
        SummaryBuffer."Amount from prev period" := SummaryBuffer."Amount from prev period" + Amount_from_prev_period;
        SummaryBuffer."Quantity from self" := SummaryBuffer."Quantity from self" + Quantity_from_self;
        SummaryBuffer."Amount from self" := SummaryBuffer."Amount from self" + Amount_from_self;
        SummaryBuffer."Cost from YL" := SummaryBuffer."Cost from YL" + costfromYL;
        SummaryBuffer."Cost from ER" := SummaryBuffer."Cost from ER" + costfromER;
        SummaryBuffer."Cost from GBE" := SummaryBuffer."Cost from GBE" + costfromGBE;
        SummaryBuffer."Total Cost" := SummaryBuffer."Total Cost" + totalcost;
        SummaryBuffer."End Quantity" := SummaryBuffer."End Quantity" + EndQuantity;
        SummaryBuffer."End Value" := SummaryBuffer."End Value" + EndValue;
        SummaryBuffer.Modify();
    end;

    // Valuation adjustments are applied after the row has already been classified from Value Entry.
    local procedure ApplyValuationCostAdjustments(ItemNo: Code[20]; LocationCode: Code[10]; PostingDate: Date; VariantCode: Code[10])
    var
        ValuationCost: Record "Valuation Cost RCGRBASE";
        ValuationUnitCost: Decimal;
        ValComp1: Decimal;
        ValComp2: Decimal;
        ValComp3: Decimal;
        ValComp4: Decimal;
    begin
        if (Quantity_from_census = 0) and (Quantity_from_prod = 0) then
            exit;

        if not FindValuationCost(ItemNo, LocationCode, PostingDate, VariantCode, ValuationCost) then
            exit;

        // Pull both the unit cost and the production components from the valuation table.
        ValuationUnitCost := ValuationCost."Valuation Cost per Unit";
        ValComp1 := ValuationCost."Cost Component 1";
        ValComp2 := ValuationCost."Cost Component 2";
        ValComp3 := ValuationCost."Cost Component 3";
        ValComp4 := ValuationCost."Cost Component 4";

        // Census keeps its quantity from Value Entry but can be revalued from the valuation table.
        if Quantity_from_census <> 0 then
            Amount_from_census := Quantity_from_census * ValuationUnitCost; //BW_TM remove wrong rounding.

        if Quantity_from_prod <> 0 then begin
            // Business mapping: 1=YLika, 2=Amesa Ergatika, 3=Fason, 4=GBE, 5=unused.
            costfromYL := ValComp1 * Quantity_from_prod;
            costfromER := ValComp2 * Quantity_from_prod;
            costfromGBE := ValComp4 * Quantity_from_prod;
            totalcost := (ValComp1 + ValComp2 + ValComp3 + ValComp4) * Quantity_from_prod;
        end;
    end;

    // Valuation records are matched by item, location, variant, and the costing period covering the posting date.
    local procedure FindValuationCost(ItemNo: Code[20]; LocationCode: Code[10]; PostingDate: Date; VariantCode: Code[10]; var ValuationCost: Record "Valuation Cost RCGRBASE"): Boolean
    var
        SelectedCostingPeriodCode: Text[50];
    begin
        if not FindCostingPeriodCode(PostingDate, SelectedCostingPeriodCode) then
            exit(false);

        exit(FindValuationCostForPeriod(ItemNo, LocationCode, VariantCode, SelectedCostingPeriodCode, ValuationCost));
    end;

    local procedure FindCostingPeriodCode(PostingDate: Date; var SelectedCostingPeriodCode: Text[50]): Boolean
    var
        CostingPeriod: Record "Costing Period RCGRBASE";
        SelectedStartingDate: Date;
    begin
        Clear(SelectedCostingPeriodCode);
        // When multiple periods cover the date, choose the one with the latest starting date.
        CostingPeriod.Reset();
        CostingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        CostingPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if not CostingPeriod.FindSet() then
            exit(false);

        repeat
            if (SelectedCostingPeriodCode = '') or (CostingPeriod."Starting Date" > SelectedStartingDate) then begin
                SelectedCostingPeriodCode := CostingPeriod.Code;
                SelectedStartingDate := CostingPeriod."Starting Date";
            end;
        until CostingPeriod.Next() = 0;

        exit(SelectedCostingPeriodCode <> '');
    end;

    local procedure FindValuationCostForPeriod(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; SelectedCostingPeriodCode: Text[50]; var ValuationCost: Record "Valuation Cost RCGRBASE"): Boolean
    begin
        if SelectedCostingPeriodCode = '' then
            exit(false);

        ValuationCost.Reset();
        ValuationCost.SetRange("Item No.", ItemNo);
        ValuationCost.SetRange("Valuation Period", SelectedCostingPeriodCode);

        // Primary: exact location + variant.
        ValuationCost.SetRange("Location Code", LocationCode);
        ValuationCost.SetRange("Variant Code", VariantCode);
        if ValuationCost.FindFirst() then
            exit(true);

        // Fallback 1: exact location, any variant.
        ValuationCost.SetRange("Variant Code");
        if ValuationCost.FindFirst() then
            exit(true);

        // Fallback 2: any location, any variant.
        ValuationCost.SetRange("Location Code");
        if ValuationCost.FindFirst() then
            exit(true);

        exit(false);
    end;

    local procedure LocationEndQuantity(ItemNo: Code[20]; LocationCode: Code[10]) Qty: Decimal
    var
        TempVE: Record "Value Entry";
        CensusCutoffDate: Date;
        MovementStartDate: Date;
    begin
        TempVE.ReadIsolation := IsolationLevel::ReadUncommitted;
        TempVE.SetRange("Item No.", ItemNo);
        TempVE.SetRange("Location Code", LocationCode);
        TempVE.SetRange("Posting Date", 0D, EndDate);
        if StartDate = 0D then begin
            TempVE.CalcSums("Item Ledger Entry Quantity");
            exit(TempVE."Item Ledger Entry Quantity");
        end;

        if Date2DMY(StartDate, 3) = 2025 then
            CensusCutoffDate := DMY2Date(31, 10, 2025)
        else
            CensusCutoffDate := CalcDate('<-1D>', StartDate);
        if CensusCutoffDate > EndDate then
            CensusCutoffDate := EndDate;

        TempVE.SetRange("Posting Date", 0D, CensusCutoffDate);
        TempVE.CalcSums("Item Ledger Entry Quantity");
        Qty := TempVE."Item Ledger Entry Quantity";

        MovementStartDate := StartDate;
        if (Date2DMY(StartDate, 3) = 2025) and (StartDate <= CensusCutoffDate) then
            MovementStartDate := CalcDate('<1D>', CensusCutoffDate);
        TempVE.SetRange("Posting Date", MovementStartDate, EndDate);
        TempVE.SetFilter("Item Ledger Entry Type", '<>%1', "Item Ledger Entry Type"::" ");
        TempVE.CalcSums("Item Ledger Entry Quantity");
        exit(Qty + TempVE."Item Ledger Entry Quantity");
    end;

    local procedure LocationHasStockAndValuationRecord(ItemNo: Code[20]; LocationCode: Code[10]): Boolean
    var
        ValCost: Record "Valuation Cost RCGRBASE";
    begin
        if LocationEndQuantity(ItemNo, LocationCode) = 0 then
            exit(false);
        if not HasEndDateValuationPeriod then
            exit(false);
        if not FindValuationCostForPeriod(ItemNo, LocationCode, '', EndDateValuationPeriodCode, ValCost) then
            exit(false);
        exit(true);
    end;

    local procedure ItemHasStockAndValuationRecord(ItemNo: Code[20]): Boolean
    var
        TempVE: Record "Value Entry";
        LastLocationCode: Code[10];
        FirstRow: Boolean;
    begin
        TempVE.ReadIsolation := IsolationLevel::ReadUncommitted;
        TempVE.SetLoadFields("Location Code");
        TempVE.SetRange("Item No.", ItemNo);
        TempVE.SetRange("Posting Date", 0D, EndDate);
        if not TempVE.SetCurrentKey("Item No.", "Location Code") then;
        if TempVE.FindSet() then begin
            FirstRow := true;
            repeat
                if FirstRow or (TempVE."Location Code" <> LastLocationCode) then begin
                    if LocationHasStockAndValuationRecord(ItemNo, TempVE."Location Code") then
                        exit(true);
                    LastLocationCode := TempVE."Location Code";
                    FirstRow := false;
                end;
            until TempVE.Next() = 0;
        end;
        exit(false);
    end;

    // Census rows use a special cutoff for 2025, otherwise they behave like the original pre-period check.
    local procedure IsCensusPostingDateEligible(PostingDate: Date): Boolean
    begin
        if StartDate = 0D then
            exit(true);

        if Date2DMY(StartDate, 3) = 2025 then
            exit(PostingDate <= DMY2Date(31, 10, 2025));

        exit(PostingDate < StartDate);
    end;

    local procedure ZeroReportQuantities()
    begin
        DisplayInvoicedQuantity := 0;
        DisplayItemLedgerEntryQuantity := 0;
        Quantity_from_transfer := 0;
        Quantity_from_transfer_exp := 0;
        Quantity_from_prev_period := 0;
        Quantity_from_purch := 0;
        Quantity_from_purch_exp := 0;
        Quantity_from_cons := 0;
        Quantity_from_census := 0;
        Quantity_from_prod := 0;
        Quantity_from_sale := 0;
        Quantity_from_sale_exp := 0;
        Quantity_from_self := 0;
        Quantity_from_other_pos := 0;
        Quantity_from_other_neg := 0;
    end;
}