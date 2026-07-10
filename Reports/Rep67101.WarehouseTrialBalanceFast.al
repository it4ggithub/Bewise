// report 67101 "BW Warehouse Item Card"
// {
//     Caption = 'BW Warehouse Item Card';
//     /*
//     *BW_TM 4/11/2024

//     *BW_TM 12/11/2024 added item and made the value entries nested dataitem so it can display all items.
//     */

//     ApplicationArea = All;
//     // DefaultLayout = RDLC;
//     // RDLCLayout = 'TestedLayouts\ItemCard.rdlc';

//     UsageCategory = ReportsAndAnalysis;
//     dataset
//     {

//         dataitem("Company Information"; "Company Information")
//         {
//             DataItemTableView = sorting("Primary Key");
//             column(Name; Name) { }
//             column(Profession; "Profession RCGRBASE") { }
//             column(Address; Address) { }
//             column(City; City) { }
//             column(Post_Code; "Post Code") { }
//             column(VAT_Registration_No_; "VAT Registration No.") { }
//             column(Tax_Office; "Tax Office RCGRBASE") { }
//             column(Picture; Picture) { }
//             column(StartDate; StartDate) { }
//             column(EndDate; EndDate) { }
//             column(LocationFilter; LocationFilter) { }
//             column(GlobalDim1Filter; GlobalDim1Filter) { }
//             column(GlobalDim2Filter; GlobalDim2Filter) { }
//             trigger OnAfterGetRecord()
//             begin
//                 LocationFilter := GetFilter("Location Code");
//                 // GlobalDim1Filter := GetFilter("Global Dimension 1 Code");
//                 // GlobalDim2Filter := GetFilter("Global Dimension 2 Code");
//             end;

//         }
//         dataitem(ValueEntries; "Value Entry")
//         {
//             RequestFilterFields = "Location Code", "Item Ledger Entry Type";

//             trigger OnPreDataItem()
//             var
//                 myInt: Integer;
//             begin
//                 SetRange("Posting Date", 0D, EndDate);
//                 Item.CopyFilter("No.", ValueEntries."Item No.");
//                 UpdateProgress('Applying Value Entry filters...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);
//             end;
//         }


//         dataitem(Item; Item)
//         {
//             DataItemTableView = sorting("No.");
//             RequestFilterFields = "No.", "Inventory Posting Group";

//             column(No_; "No.") { }
//             column(ItemNo; "No.") { }
//             column(Description; Description) { }
//             column(Inventory_Posting_Group; "Inventory Posting Group") { }
//             column(Item_Category_Code; "Item Category Code") { }
//             // column(Item_Category_1; "Item Category 1") { }
//             // column(Item_Category_2; "Item Category 2") { }
//             // column(Item_Category_3; "Item Category 3") { }
//             // column(Item_Category_4; "Item Category 4") { }
//             // column(Item_Category_5; "Item Category 5") { }

//             column(HasValueEntry; HasValueEntry) { } // added for hidding logic in RDL

//             dataitem(GroupLoop; Integer)
//             {
//                 DataItemTableView = sorting(Number);
//                 column(PostingDate; TempValueEntryGroup."Posting Date")
//                 {
//                 }
//                 column(ItemLedgerEntryType; TempValueEntryGroup."Item Ledger Entry Type")
//                 {
//                 }
//                 column(InvoicedQuantity; TempValueEntryGroup."Invoiced Quantity")
//                 {
//                 }
//                 column(ItemLedgerEntryQuantity; TempValueEntryGroup."Item Ledger Entry Quantity")
//                 {
//                 }
//                 column(LocationCode; TempValueEntryGroup."Location Code")
//                 {
//                 }
//                 column(GlobalDimension1Code; TempValueEntryGroup."Global Dimension 1 Code")
//                 {
//                 }
//                 column(GlobalDimension2Code; TempValueEntryGroup."Global Dimension 2 Code")
//                 {
//                 }
//                 column(GenProdPostingGroup; TempValueEntryGroup."Gen. Prod. Posting Group")
//                 {
//                 }
//                 column(ExternalDocumentNo; TempValueEntryGroup."External Document No.")
//                 {
//                 }
//                 column(SourceNo; TempValueEntryGroup."Source No.")
//                 {
//                 }
//                 column(SourcePostingGroup; TempValueEntryGroup."Source Posting Group")
//                 {
//                 }

//                 column(Amount_from_purch; Amount_from_purch) { }
//                 column(Amount_from_purch_exp; Amount_from_purch_exp) { }
//                 column(Amount_from_sale; Amount_from_sale) { }
//                 column(Amount_from_sale_exp; Amount_from_sale_exp) { }
//                 column(Cost_from_sale; Cost_from_sale) { }
//                 column(Cost_from_sale_exp; Cost_from_sale_exp) { }
//                 column(Amount_from_cons; Amount_from_cons) { }
//                 column(Amount_from_prod; Amount_from_prod) { }
//                 column(Amount_from_other_neg; Amount_from_other_neg) { }
//                 column(Amount_from_other_pos; Amount_from_other_pos) { }
//                 column(Quantity_from_purch; Quantity_from_purch) { }
//                 column(Quantity_from_purch_exp; Quantity_from_purch_exp) { }
//                 column(Quantity_from_sale; Quantity_from_sale) { }
//                 column(Quantity_from_sale_exp; Quantity_from_sale_exp) { }
//                 column(Quantity_from_prod; Quantity_from_prod) { }
//                 column(Quantity_from_cons; Quantity_from_cons) { }
//                 column(Quantity_from_other_pos; Quantity_from_other_pos) { }
//                 column(Quantity_from_other_neg; Quantity_from_other_neg) { }
//                 column(countN; countN) { }
//                 column(Quantity_from_transfer; Quantity_from_transfer) { }
//                 column(Quantity_from_transfer_exp; Quantity_from_transfer_exp) { }
//                 column(Amount_from_transfer; Amount_from_transfer) { }
//                 column(Quantity_from_self; Quantity_from_self) { }
//                 column(Amount_from_self; Amount_from_self) { }
//                 // column(item_description; item_description) { }
//                 // column(item_logcat; item_logcat) { }
//                 column(Document_No_; TempValueEntryGroup."Document No.") { }
//                 column(Document_Type; TempValueEntryGroup."Document Type") { }
//                 column(Tm_Name; Name) { }
//                 column(UnitOfMeas; UnitOfMeas) { }
//                 column(Reason_Code; TempValueEntryGroup."Reason Code") { }
//                 column(costfromYL; costfromYL) { }
//                 column(costfromER; costfromER) { }
//                 column(costfromGBE; costfromGBE) { }
//                 column(totalcost; totalcost) { }

//                 column(itemAA; ItemCounter) { }
//                 //added this data item to incoporate the zone code

//                 trigger OnPreDataItem()
//                 begin
//                     if GroupCount = 0 then begin
//                         CurrReport.Break();
//                     end;

//                     SetRange(Number, 1, GroupCount);
//                     TempValueEntryGroup.Reset();
//                     TempValueEntryGroup.FindSet();
//                 end;

//                 trigger OnAfterGetRecord()
//                 var
//                     location: Record Location;
//                     Vendors: Record Vendor;
//                     Customers: Record Customer;
//                     dimension: Record Dimension;
//                 begin
//                     // Move to the current grouped row before evaluating columns.
//                     if Number > 1 then
//                         TempValueEntryGroup.Next();

//                     ProcessedGroupRowCount += 1;
//                     if (ProcessedGroupRowCount mod 100) = 0 then
//                         UpdateProgress('Rendering grouped rows...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);

//                     Clear(loc_des);
//                     if location.Get(VE."Location Code") then begin
//                         loc_des := location.Name
//                     end;

//                     // Get Unit of Measurment
//                     clear(UnitOfMeas);
//                     UnitOfMeas := item."Base Unit of Measure";

//                     //Get zone code


//                     Clear(Quantity_from_transfer);
//                     Clear(Amount_from_transfer);
//                     Clear(Quantity_from_transfer_exp);

//                     // Logic for populating transfer-related values based on posting date
//                     if StartDate <> 0D then begin
//                         // ek metaforas kanonika
//                         if (TempValueEntryGroup."Posting Date" < StartDate) then begin
//                             // Quantity_from_transfer := "Invoiced Quantity";
//                             // Quantity_from_transfer_exp := "Item Ledger Entry Quantity";
//                             // if VE."Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
//                             //     Quantity_from_transfer := VE."Invoiced Quantity";
//                             //     Quantity_from_transfer_exp := -VE."Invoiced Quantity";
//                             // end else if VE."Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
//                             //     Quantity_from_transfer := VE."Invoiced Quantity";
//                             // end else begin
//                             Quantity_from_transfer := TempValueEntryGroup."Item Ledger Entry Quantity"; // here are receipts
//                             // end;
//                             Amount_from_transfer := TempValueEntryGroup."Cost Amount (Actual)";
//                         end;

//                         if TempValueEntryGroup."Posting Date" >= StartDate then begin
//                             countN := countN + 1;
//                         end;
//                     end
//                     else begin

//                         countN := countN + 1;

//                     end;

//                     // Clear transaction amounts and quantities before calculating new values

//                     Clear(Quantity_from_purch);
//                     Clear(Quantity_from_purch_exp);
//                     Clear(Quantity_from_sale);
//                     Clear(Quantity_from_sale_exp);
//                     Clear(Quantity_from_prod);
//                     Clear(Amount_from_prod);
//                     Clear(Quantity_from_cons);
//                     Clear(Amount_from_cons);
//                     Clear(Quantity_from_other_pos);
//                     Clear(Quantity_from_other_neg);
//                     Clear(Amount_from_other_pos);
//                     Clear(Amount_from_other_neg);
//                     Clear(Amount_from_purch);
//                     Clear(Amount_from_purch_exp);
//                     Clear(Amount_from_sale);
//                     Clear(Amount_from_sale_exp);
//                     Clear(Cost_from_sale);
//                     Clear(Cost_from_sale_exp);
//                     Clear(costfromYL);
//                     Clear(costfromER);
//                     Clear(costfromGBE);
//                     Clear(totalcost);

//                     // Logic to handle different types of item ledger entries (Purchase, Sale, Output, etc.)

//                     if TempValueEntryGroup."Posting Date" >= StartDate then begin

//                         case TempValueEntryGroup."Item Ledger Entry Type" of

//                             TempValueEntryGroup."Item Ledger Entry Type"::Purchase:
//                                 begin
//                                     // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
//                                     // Quantity_from_purch := "Item Ledger Entry Quantity";
//                                     if TempValueEntryGroup."Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a receipt
//                                         Quantity_from_purch := TempValueEntryGroup."Invoiced Quantity";
//                                         Quantity_from_purch_exp := -TempValueEntryGroup."Invoiced Quantity";
//                                     end else if TempValueEntryGroup."Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a receipt
//                                         Quantity_from_purch := TempValueEntryGroup."Invoiced Quantity";
//                                     end else begin
//                                         Quantity_from_purch_exp := TempValueEntryGroup."Item Ledger Entry Quantity"; // here are receipts
//                                     end;


//                                     // Quantity_from_purch := "Invoiced Quantity";
//                                     Amount_from_purch := TempValueEntryGroup."Purchase Amount (Actual)";
//                                     Amount_from_purch_exp := TempValueEntryGroup."Purchase Amount (Expected)";

//                                 end;

//                             TempValueEntryGroup."Item Ledger Entry Type"::Sale:
//                                 begin
//                                     // Goal is when I sum all values for an item to have a value (Quantity_from_purch_exp) that symbolises the quantity that has been shipped but not invoiced.
//                                     //Quantity_from_sale := "Item Ledger Entry Quantity";
//                                     if TempValueEntryGroup."Item Ledger Entry Quantity" = 0 then begin  // here are invoices based on a shipment
//                                         Quantity_from_sale := TempValueEntryGroup."Invoiced Quantity";
//                                         Quantity_from_sale_exp := -TempValueEntryGroup."Invoiced Quantity";
//                                     end else if TempValueEntryGroup."Invoiced Quantity" <> 0 then begin // here are invoices NOT based on a shipment
//                                         Quantity_from_sale := TempValueEntryGroup."Invoiced Quantity";
//                                     end else begin
//                                         Quantity_from_sale_exp := TempValueEntryGroup."Item Ledger Entry Quantity"; // here are Shipments
//                                     end;
//                                     // Quantity_from_sale := "Invoiced Quantity";
//                                     // Quantity_from_sale_exp := "Item Ledger Entry Quantity";
//                                     Amount_from_sale := TempValueEntryGroup."Sales Amount (Actual)";
//                                     Amount_from_sale_exp := TempValueEntryGroup."Sales Amount (Expected)";
//                                     Cost_from_sale := TempValueEntryGroup."Cost Amount (Actual)";
//                                     Cost_from_sale_exp := TempValueEntryGroup."Cost Amount (Expected)";


//                                 end;
//                             TempValueEntryGroup."Item Ledger Entry Type"::Output:
//                                 begin
//                                     Quantity_from_prod := TempValueEntryGroup."Item Ledger Entry Quantity";
//                                     Amount_from_prod := TempValueEntryGroup."Cost Amount (Actual)";
//                                     //? cost from ---
//                                     costfromYL := TempValueEntryGroup."Cost Component 1 RCGRBASE";
//                                     costfromER := TempValueEntryGroup."Cost Component 3 RCGRBASE";
//                                     costfromGBE := TempValueEntryGroup."Cost Component 2 RCGRBASE";
//                                     totalcost := costfromYL + costfromER + costfromGBE;
//                                 end;
//                             //??? what do I do with this ?????????????????????
//                             TempValueEntryGroup."Item Ledger Entry Type"::" ":
//                                 begin
//                                     Clear(costfromYL);
//                                     Clear(costfromER);
//                                     Clear(costfromGBE);
//                                     Clear(totalcost);
//                                 end;
//                             TempValueEntryGroup."Item Ledger Entry Type"::Consumption:
//                                 begin
//                                     if TempValueEntryGroup."Cost Component 2 RCGRBASE" <> 0 then begin
//                                         // subproduct production
//                                         Quantity_from_prod := TempValueEntryGroup."Item Ledger Entry Quantity";
//                                         Amount_from_prod := TempValueEntryGroup."Cost Amount (Actual)";
//                                         //? cost from ---
//                                         costfromYL := TempValueEntryGroup."Cost Component 1 RCGRBASE";
//                                         costfromER := TempValueEntryGroup."Cost Component 3 RCGRBASE";
//                                         costfromGBE := TempValueEntryGroup."Cost Component 2 RCGRBASE";
//                                         totalcost := costfromYL + costfromER + costfromGBE;
//                                     end else begin
//                                         Quantity_from_cons := TempValueEntryGroup."Item Ledger Entry Quantity";
//                                         Amount_from_cons := TempValueEntryGroup."Cost Amount (Actual)";
//                                     end;
//                                     // if "Item Ledger Entry Quantity" < 0 then begin

//                                     // end else begin // arnitiki analwsi einai paragwgi
//                                     //     Quantity_from_prod := "Item Ledger Entry Quantity";
//                                     //     Amount_from_prod := "Cost Amount (Actual)";
//                                     //     //? cost from ---
//                                     //     costfromYL := "Cost Component 1 RCGRBASE";
//                                     //     costfromER := "Cost Component 3 RCGRBASE";
//                                     //     costfromGBE := "Cost Component 2 RCGRBASE";
//                                     //     totalcost := costfromYL + costfromER + costfromGBE;
//                                     // end;

//                                 end;

//                             else begin

//                                 if TempValueEntryGroup."Item Ledger Entry Quantity" > 0 then begin
//                                     Quantity_from_other_pos := TempValueEntryGroup."Item Ledger Entry Quantity";
//                                 end
//                                 else begin
//                                     Quantity_from_other_neg := TempValueEntryGroup."Item Ledger Entry Quantity";
//                                 end;

//                                 if TempValueEntryGroup."Cost Amount (Actual)" > 0 then begin
//                                     Amount_from_other_pos := TempValueEntryGroup."Cost Amount (Actual)";
//                                 end
//                                 else begin
//                                     Amount_from_other_neg := TempValueEntryGroup."Cost Amount (Actual)";
//                                 end;
//                             end;
//                         end;
//                     end;

//                     // cases of Source Types need to call difrent table each time :( 
//                     case TempValueEntryGroup."Source Type" of
//                         TempValueEntryGroup."Source Type"::Customer:
//                             begin
//                                 if Customers.get(TempValueEntryGroup."Source No.") then begin
//                                     Name := Customers.Name;
//                                 end;
//                             end;
//                         TempValueEntryGroup."Source Type"::Vendor:
//                             begin
//                                 if Vendors.get(TempValueEntryGroup."Source No.") then begin
//                                     Name := Vendors.Name;
//                                 end;
//                             end;


//                         else
//                             Name := '';

//                     end;

//                 end;
//             }



//             trigger OnPreDataItem()

//             begin
//                 ItemCounter := 0;
//             end;

//             trigger OnAfterGetRecord()
//             var
//                 CounterValue: Integer;
//                 HasMovementInPeriod: Boolean;
//             begin

//                 ItemCounter := ItemCounter + 1;
//                 ProcessedItemCount += 1;
//                 UpdateProgress('Processing item...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);


//                 TempValueEntryGroup.Reset();
//                 if not TempValueEntryGroup.IsEmpty then
//                     TempValueEntryGroup.DeleteAll();
//                 GroupCount := 0;
//                 NextGroupEntryNo := 1;
//                 HasMovementInPeriod := false;

//                 // Get location Name
//                 VE.Reset();
//                 VE.CopyFilters(ValueEntries);
//                 VE.SetRange("Item No.", Item."No.");

//                 if VE.FindSet() then
//                     repeat
//                         ProcessedValueEntryCount += 1;
//                         if (ProcessedValueEntryCount mod 200) = 0 then
//                             UpdateProgress('Scanning Value Entries...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);

//                         if (StartDate = 0D) or (VE."Posting Date" >= StartDate) then
//                             HasMovementInPeriod := true;

//                         UpsertValueEntryGroup(VE);
//                     Until VE.Next() = 0;

//                 HasValueEntry := GroupCount > 0;

//                 if HideItemsWithoutValueEntries and (not HasMovementInPeriod) then begin
//                     UpdateProgress('Skipping item without movement in period...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);
//                     CurrReport.Skip();
//                 end;

//                 UpdateProgress('Grouped current item...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);


//             end;

//         }

//     }
//     requestpage
//     {
//         SaveValues = true;
//         layout
//         {
//             area(Content)
//             {
//                 group("Date Filter")
//                 {
//                     field(StartDate; StartDate)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Starting Date';
//                     }
//                     field(EndDate; EndDate)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Ending Date';
//                     }

//                 }
//                 // group("Options")
//                 group("Options")
//                 {
//                     field(HideItemsWithoutValueEntries; HideItemsWithoutValueEntries)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Hide Items Without Movement In Period';
//                     }
//                 }
//             }
//         }
//         // trigger OnOpenPage()
//         // begin

//         //     if EndDate = 0D then
//         //         EndDate := Today;

//         // end;

//     }

//     trigger OnPreReport()
//     begin
//         ProcessedItemCount := 0;
//         ProcessedValueEntryCount := 0;
//         ProcessedGroupRowCount := 0;

//         if GuiAllowed then
//             ProgressDialog.Open(
//                 'BW Warehouse Item Card progress\\' +
//                 'Status: #1#############################\\' +
//                 'Items processed: #2#####################\\' +
//                 'Value Entries scanned: #3###############\\' +
//                 'Grouped rows output: #4#################');

//         UpdateProgress('Starting report...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);
//     end;

//     trigger OnPostReport()
//     begin
//         UpdateProgress('Finishing report...', ProcessedItemCount, ProcessedValueEntryCount, ProcessedGroupRowCount);

//         if GuiAllowed then
//             ProgressDialog.Close();
//     end;


//     var
//         VE: Record "Value Entry";
//         TempValueEntryGroup: Record "Value Entry" temporary;
//         StartDate: Date;
//         EndDate: Date;
//         // item_description: Text[100];
//         // item_logcat: Code[20];
//         Quantity_from_transfer: Decimal;
//         Quantity_from_transfer_exp: Decimal;
//         Quantity_from_purch: Decimal;
//         Quantity_from_purch_exp: Decimal;
//         Quantity_from_cons: Decimal;
//         Quantity_from_prod: Decimal;
//         Quantity_from_sale: Decimal;
//         Quantity_from_sale_exp: Decimal;
//         Quantity_from_self: Decimal;
//         Quantity_from_other_pos: Decimal;
//         Quantity_from_other_neg: Decimal;
//         Amount_from_transfer: Decimal;
//         Amount_from_purch: Decimal;
//         Amount_from_purch_exp: Decimal;
//         Amount_from_cons: Decimal;
//         Amount_from_prod: Decimal;
//         Amount_from_sale: Decimal;
//         Amount_from_sale_exp: Decimal;
//         Amount_from_self: Decimal;
//         Amount_from_other_pos: Decimal;
//         Amount_from_other_neg: Decimal;
//         Cost_from_AYlik: Decimal;
//         Cost_from_AErg: Decimal;
//         Cost_from_GBE: Decimal;
//         Cost_from_sale: Decimal;
//         Cost_from_sale_exp: Decimal;
//         countN: Integer;
//         Name: Text[100];
//         ItemCounter: Integer; // Variable for the item counter to be displayed in ItemAA
//         UnitOfMeas: Code[20];
//         loc_des: text[100];
//         LocationFilter: Text[100];
//         GlobalDim1Filter: Text[100];
//         GlobalDim2Filter: Text[100];
//         HideItemsWithoutValueEntries: Boolean;
//         HasValueEntry: Boolean;
//         zoneCode: Code[10]; // variable for Zones
//         costfromYL: Decimal;
//         costfromER: Decimal;
//         costfromGBE: Decimal;
//         totalcost: Decimal;
//         GroupCount: Integer;
//         NextGroupEntryNo: Integer;
//         ProgressDialog: Dialog;
//         ProcessedItemCount: Integer;
//         ProcessedValueEntryCount: Integer;
//         ProcessedGroupRowCount: Integer;
//         TempVE: Record "Value Entry" temporary;

//     local procedure UpdateProgress(StatusTxt: Text; ItemsDone: Integer; ValueEntriesDone: Integer; GroupRowsDone: Integer)
//     begin
//         if not GuiAllowed then
//             exit;

//         ProgressDialog.Update(1, StatusTxt);
//         ProgressDialog.Update(2, ItemsDone);
//         ProgressDialog.Update(3, ValueEntriesDone);
//         ProgressDialog.Update(4, GroupRowsDone);
//     end;

//     local procedure UpsertValueEntryGroup(var ValueEntryRec: Record "Value Entry")
//     begin
//         TempValueEntryGroup.Reset();
//         TempValueEntryGroup.SetRange("Item No.", ValueEntryRec."Item No.");
//         TempValueEntryGroup.SetRange("Posting Date", ValueEntryRec."Posting Date");
//         TempValueEntryGroup.SetRange("Document No.", ValueEntryRec."Document No.");
//         TempValueEntryGroup.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type");
//         TempValueEntryGroup.SetRange("Source No.", ValueEntryRec."Source No.");
//         TempValueEntryGroup.SetRange("Source Type", ValueEntryRec."Source Type");

//         if TempValueEntryGroup.FindFirst() then begin
//             TempValueEntryGroup."Invoiced Quantity" += ValueEntryRec."Invoiced Quantity";
//             TempValueEntryGroup."Item Ledger Entry Quantity" += ValueEntryRec."Item Ledger Entry Quantity";
//             TempValueEntryGroup."Cost Amount (Actual)" += ValueEntryRec."Cost Amount (Actual)";
//             TempValueEntryGroup."Cost Amount (Expected)" += ValueEntryRec."Cost Amount (Expected)";
//             TempValueEntryGroup."Purchase Amount (Actual)" += ValueEntryRec."Purchase Amount (Actual)";
//             TempValueEntryGroup."Purchase Amount (Expected)" += ValueEntryRec."Purchase Amount (Expected)";
//             TempValueEntryGroup."Sales Amount (Actual)" += ValueEntryRec."Sales Amount (Actual)";
//             TempValueEntryGroup."Sales Amount (Expected)" += ValueEntryRec."Sales Amount (Expected)";
//             TempValueEntryGroup."Cost Component 1 RCGRBASE" += ValueEntryRec."Cost Component 1 RCGRBASE";
//             TempValueEntryGroup."Cost Component 2 RCGRBASE" += ValueEntryRec."Cost Component 2 RCGRBASE";
//             TempValueEntryGroup."Cost Component 3 RCGRBASE" += ValueEntryRec."Cost Component 3 RCGRBASE";
//             TempValueEntryGroup."Cost Component 4 RCGRBASE" += ValueEntryRec."Cost Component 4 RCGRBASE";
//             TempValueEntryGroup."Cost Component 5 RCGRBASE" += ValueEntryRec."Cost Component 5 RCGRBASE";
//             TempValueEntryGroup.Modify();
//         end else begin
//             TempValueEntryGroup.Init();
//             TempValueEntryGroup."Entry No." := NextGroupEntryNo;
//             NextGroupEntryNo += 1;

//             TempValueEntryGroup."Item No." := ValueEntryRec."Item No.";
//             TempValueEntryGroup."Reason Code" := ValueEntryRec."Reason Code";
//             TempValueEntryGroup."Posting Date" := ValueEntryRec."Posting Date";
//             TempValueEntryGroup."Document No." := ValueEntryRec."Document No.";
//             TempValueEntryGroup."Location Code" := ValueEntryRec."Location Code";
//             TempValueEntryGroup."Global Dimension 1 Code" := ValueEntryRec."Global Dimension 1 Code";
//             TempValueEntryGroup."Global Dimension 2 Code" := ValueEntryRec."Global Dimension 2 Code";
//             TempValueEntryGroup."Gen. Prod. Posting Group" := ValueEntryRec."Gen. Prod. Posting Group";
//             TempValueEntryGroup."External Document No." := ValueEntryRec."External Document No.";
//             TempValueEntryGroup."Document Type" := ValueEntryRec."Document Type";
//             TempValueEntryGroup."Item Ledger Entry Type" := ValueEntryRec."Item Ledger Entry Type";
//             TempValueEntryGroup."Source No." := ValueEntryRec."Source No.";
//             TempValueEntryGroup."Source Type" := ValueEntryRec."Source Type";
//             TempValueEntryGroup."Invoiced Quantity" := ValueEntryRec."Invoiced Quantity";
//             TempValueEntryGroup."Item Ledger Entry Quantity" := ValueEntryRec."Item Ledger Entry Quantity";
//             TempValueEntryGroup."Cost Amount (Actual)" := ValueEntryRec."Cost Amount (Actual)";
//             TempValueEntryGroup."Cost Amount (Expected)" := ValueEntryRec."Cost Amount (Expected)";
//             TempValueEntryGroup."Purchase Amount (Actual)" := ValueEntryRec."Purchase Amount (Actual)";
//             TempValueEntryGroup."Purchase Amount (Expected)" := ValueEntryRec."Purchase Amount (Expected)";
//             TempValueEntryGroup."Sales Amount (Actual)" := ValueEntryRec."Sales Amount (Actual)";
//             TempValueEntryGroup."Sales Amount (Expected)" := ValueEntryRec."Sales Amount (Expected)";
//             TempValueEntryGroup."Cost Component 1 RCGRBASE" := ValueEntryRec."Cost Component 1 RCGRBASE";
//             TempValueEntryGroup."Cost Component 2 RCGRBASE" := ValueEntryRec."Cost Component 2 RCGRBASE";
//             TempValueEntryGroup."Cost Component 3 RCGRBASE" := ValueEntryRec."Cost Component 3 RCGRBASE";
//             TempValueEntryGroup."Cost Component 4 RCGRBASE" := ValueEntryRec."Cost Component 4 RCGRBASE";
//             TempValueEntryGroup."Cost Component 5 RCGRBASE" := ValueEntryRec."Cost Component 5 RCGRBASE";
//             TempValueEntryGroup.Insert();
//             GroupCount += 1;
//         end;

//         TempValueEntryGroup.Reset();
//     end;
// }
