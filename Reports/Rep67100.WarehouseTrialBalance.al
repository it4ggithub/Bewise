report 67100 "Warehouse Trial Balance"
{
    ApplicationArea = All;
    Caption = 'Warehouse Trial Balance BW';

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
                // These columns are consumed directly by the RDLC layout.
                column(HasValueEntry; HasValueEntry) { } // added for hidding logic in RDL
                column(PostingDate; "Posting Date")
                {
                }
                column(ItemLedgerEntryType; "Item Ledger Entry Type")
                {
                }
                column(ItemNo; "Item No.")
                {
                }
                column(InvoicedQuantity; DisplayInvoicedQuantity)
                {
                }
                column(ItemLedgerEntryQuantity; DisplayItemLedgerEntryQuantity)
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
                // column(item_description; item_description) { }
                // column(item_logcat; item_logcat) { }
                column(Document_No_; "Document No.") { }
                column(Document_Type; "Document Type") { }
                column(Tm_Name; Name) { }
                column(UnitOfMeas; UnitOfMeas) { }
                column(Reason_Code; "Reason Code") { }
                column(costfromYL; costfromYL) { }
                column(costfromER; costfromER) { }
                column(costfromGBE; costfromGBE) { }
                column(totalcost; totalcost) { }


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
                    item: Record Item;
                    CounterValue: Integer;
                    Vendors: Record Vendor;
                    Customers: Record Customer;
                    dimension: Record Dimension;
                    location: Record Location;
                    PrevPeriodStartDate: Date;
                    PrevPeriodEndDate: Date;
                    IsCensusEntry: Boolean;
                    IsEsilOnlyValue: Boolean;

                begin

                    DisplayInvoicedQuantity := "Invoiced Quantity";
                    DisplayItemLedgerEntryQuantity := "Item Ledger Entry Quantity";

                    // Get location Name
                    Clear(loc_des);
                    if location.Get("Location Code") then begin
                        loc_des := location.Name
                    end;

                    // Get Unit of Measurment
                    clear(UnitOfMeas);
                    Clear(IsEsilOnlyValue);
                    if item.Get("Item No.") then begin
                        // item_description := item.Description;
                        // item_logcat := item."Inventory Posting Group";
                        UnitOfMeas := item."Base Unit of Measure";
                        IsEsilOnlyValue := item."ESIL Only Value";
                    end;

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
                                if Customers.get("Source No.") then begin
                                    Name := Customers.Name;
                                end;
                            end;
                        "Source Type"::Vendor:
                            begin
                                if Vendors.get("Source No.") then begin
                                    Name := Vendors.Name;
                                end;
                            end;


                        else
                            Name := '';

                    end;




                end;


            }
            trigger OnPreDataItem()

            begin
                // Read item master data without taking stronger locks than necessary.
                Item.ReadIsolation := IsolationLevel::ReadUncommitted;
                ItemCounter := 0;
            end;

            trigger OnAfterGetRecord()

            begin

                // Simple running counter used by the layout.
                ItemCounter := ItemCounter + 1;

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
        UseValuationCostForProduction: Boolean;

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
        CostingPeriod: Record "Costing Period RCGRBASE";
        SelectedCostingPeriodCode: Text[50];
        SelectedStartingDate: Date;
    begin
        // When multiple periods cover the date, choose the one with the latest starting date.
        CostingPeriod.Reset();
        CostingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        CostingPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if CostingPeriod.FindSet() then
            repeat
                if (SelectedCostingPeriodCode = '') or (CostingPeriod."Starting Date" > SelectedStartingDate) then begin
                    SelectedCostingPeriodCode := CostingPeriod.Code;
                    SelectedStartingDate := CostingPeriod."Starting Date";
                end;
            until CostingPeriod.Next() = 0
        else
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