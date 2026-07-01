report 67100 "Warehouse Trial Balance"
{
    ApplicationArea = All;
    Caption = 'Warehouse Trial Balance BW';

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
            // column(Item_Category_1; "Item Category 1") { }
            // column(Item_Category_2; "Item Category 2") { }
            // column(Item_Category_3; "Item Category 3") { }
            // column(Item_Category_4; "Item Category 4") { }
            // column(Item_Category_5; "Item Category 5") { }


            column(itemAA; ItemCounter) { }
            //added this data item to incoporate the zone code


            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Posting Date");

                RequestFilterFields = "Location Code";
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
                column(Quantity_from_other_pos; Quantity_from_other_pos) { }
                column(Quantity_from_other_neg; Quantity_from_other_neg) { }
                column(countN; countN) { }
                column(Quantity_from_transfer; Quantity_from_transfer) { }
                column(Quantity_from_transfer_exp; Quantity_from_transfer_exp) { }
                column(Amount_from_transfer; Amount_from_transfer) { }
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

                begin

                    // Get location Name
                    Clear(loc_des);
                    if location.Get("Location Code") then begin
                        loc_des := location.Name
                    end;

                    // Get Unit of Measurment
                    clear(UnitOfMeas);
                    if item.Get("Item No.") then begin
                        // item_description := item.Description;
                        // item_logcat := item."Inventory Posting Group";
                        UnitOfMeas := item."Base Unit of Measure";
                    end;

                    //Get zone code


                    Clear(Quantity_from_transfer);
                    Clear(Amount_from_transfer);
                    Clear(Quantity_from_transfer_exp);

                    // Logic for populating transfer-related values based on posting date
                    if StartDate <> 0D then begin
                        // ek metaforas kanonika
                        if ("Posting Date" < StartDate) then begin
                            // Quantity_from_transfer := "Invoiced Quantity";
                            // Quantity_from_transfer_exp := "Item Ledger Entry Quantity";
                            if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
                                Quantity_from_transfer := "Invoiced Quantity";
                                Quantity_from_transfer_exp := -"Invoiced Quantity";
                            end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
                                Quantity_from_transfer := "Invoiced Quantity";
                            end else begin
                                Quantity_from_transfer_exp := "Item Ledger Entry Quantity"; // here are receipts
                            end;
                            Amount_from_transfer := "Cost Amount (Actual)";
                        end;

                        if "Posting Date" >= StartDate then begin
                            countN := countN + 1;
                        end;
                    end
                    else begin

                        countN := countN + 1;

                    end;

                    // Clear transaction amounts and quantities before calculating new values

                    Clear(Quantity_from_purch);
                    Clear(Quantity_from_purch_exp);
                    Clear(Quantity_from_sale);
                    Clear(Quantity_from_sale_exp);
                    Clear(Quantity_from_prod);
                    Clear(Amount_from_prod);
                    Clear(Quantity_from_cons);
                    Clear(Amount_from_cons);
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

                    // Logic to handle different types of item ledger entries (Purchase, Sale, Output, etc.)

                    if "Posting Date" >= StartDate then begin

                        case "Item Ledger Entry Type" of

                            "Item Ledger Entry Type"::Purchase:
                                begin
                                    // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
                                    // Quantity_from_purch := "Item Ledger Entry Quantity";
                                    if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
                                        Quantity_from_purch := "Invoiced Quantity";
                                        Quantity_from_purch_exp := -"Invoiced Quantity";
                                    end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
                                        Quantity_from_purch := "Invoiced Quantity";
                                    end else begin
                                        Quantity_from_purch_exp := "Item Ledger Entry Quantity"; // here are receipts
                                    end;


                                    // Quantity_from_purch := "Invoiced Quantity";
                                    Amount_from_purch := "Purchase Amount (Actual)";
                                    Amount_from_purch_exp := "Purchase Amount (Expected)";

                                end;

                            "Item Ledger Entry Type"::Sale:
                                begin
                                    // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
                                    //Quantity_from_sale := "Item Ledger Entry Quantity";
                                    if "Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a shipment
                                        Quantity_from_sale := "Invoiced Quantity";
                                        Quantity_from_sale_exp := -"Invoiced Quantity";
                                    end else if "Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a shipment
                                        Quantity_from_sale := "Invoiced Quantity";
                                    end else begin
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
                                    Clear(costfromYL);
                                    Clear(costfromER);
                                    Clear(costfromGBE);
                                    Clear(totalcost);
                                end;
                            "Item Ledger Entry Type"::Consumption:
                                begin
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

                    // cases of Source Types need to call difrent table each time :( 
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
                ItemCounter := 0;
            end;

            trigger OnAfterGetRecord()

            begin

                ItemCounter := ItemCounter + 1;

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
                // group("Options")
                // {
                //     field(HideItemsWithoutValueEntries; HideItemsWithoutValueEntries)
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Hide Items Without Value Entries';
                //     }
                // }
            }
        }
        // trigger OnOpenPage()
        // begin

        //     if EndDate = 0D then
        //         EndDate := Today;

        // end;

    }


    var
        StartDate: Date;
        EndDate: Date;
        // item_description: Text[100];
        // item_logcat: Code[20];
        Quantity_from_transfer: Decimal;
        Quantity_from_transfer_exp: Decimal;
        Quantity_from_purch: Decimal;
        Quantity_from_purch_exp: Decimal;
        Quantity_from_cons: Decimal;
        Quantity_from_prod: Decimal;
        Quantity_from_sale: Decimal;
        Quantity_from_sale_exp: Decimal;
        Quantity_from_self: Decimal;
        Quantity_from_other_pos: Decimal;
        Quantity_from_other_neg: Decimal;
        Amount_from_transfer: Decimal;
        Amount_from_purch: Decimal;
        Amount_from_purch_exp: Decimal;
        Amount_from_cons: Decimal;
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
}