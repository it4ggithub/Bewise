// report 67102 "Warehouse Trial Balance Val"
// {
//     ApplicationArea = All;
//     Caption = 'Warehouse Trial Balance BW Valuation';
//     DefaultLayout = RDLC;

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
//                 LocationFilter := '';
//                 GlobalDim1Filter := '';
//                 GlobalDim2Filter := '';
//             end;
//         }

//         dataitem(Item; Item)
//         {
//             DataItemTableView = sorting("No.");
//             RequestFilterFields = "No.", "Inventory Posting Group";

//             column(No_; "No.") { }
//             column(Description; Description) { }
//             column(Inventory_Posting_Group; "Inventory Posting Group") { }
//             column(Item_Category_Code; "Item Category Code") { }
//             column(Item_Category_1; Item_Category_1) { }
//             column(Item_Category_2; Item_Category_2) { }
//             column(Item_Category_3; Item_Category_3) { }
//             column(Item_Category_4; Item_Category_4) { }
//             column(Item_Category_5; Item_Category_5) { }
//             column(itemAA; ItemCounter) { }

//             dataitem(ValuationCost; "Valuation Cost RCGRBASE")
//             {
//                 DataItemLink = "Item No." = field("No.");
//                 DataItemTableView = sorting("Item No.", "Variant Code", "Valuation Period", "Location Code");
//                 RequestFilterFields = "Location Code", "Valuation Period";

//                 column(HasValueEntry; HasValueEntry) { }
//                 column(PostingDate; PostingDate) { }
//                 column(ItemLedgerEntryType; ItemLedgerEntryType) { }
//                 column(ItemNo; "Item No.") { }
//                 column(InvoicedQuantity; InvoicedQuantity) { }
//                 column(ItemLedgerEntryQuantity; ItemLedgerEntryQuantity) { }
//                 column(LocationCode; "Location Code") { }
//                 column(GlobalDimension1Code; GlobalDimension1Code) { }
//                 column(GlobalDimension2Code; GlobalDimension2Code) { }
//                 column(GenProdPostingGroup; GenProdPostingGroup) { }
//                 column(ExternalDocumentNo; ExternalDocumentNo) { }
//                 column(SourceNo; SourceNo) { }
//                 column(SourcePostingGroup; SourcePostingGroup) { }
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
//                 column(Quantity_from_census; Quantity_from_census) { }
//                 column(Quantity_from_other_pos; Quantity_from_other_pos) { }
//                 column(Quantity_from_other_neg; Quantity_from_other_neg) { }
//                 column(countN; countN) { }
//                 column(Quantity_from_transfer; Quantity_from_transfer) { }
//                 column(Quantity_from_transfer_exp; Quantity_from_transfer_exp) { }
//                 column(Amount_from_transfer; Amount_from_transfer) { }
//                 column(Amount_from_census; Amount_from_census) { }
//                 column(Quantity_from_prev_period; Quantity_from_prev_period) { }
//                 column(Amount_from_prev_period; Amount_from_prev_period) { }
//                 column(Quantity_from_self; Quantity_from_self) { }
//                 column(Amount_from_self; Amount_from_self) { }
//                 column(Document_No_; Document_No_) { }
//                 column(Document_Type; Document_Type) { }
//                 column(Tm_Name; Tm_Name) { }
//                 column(UnitOfMeas; UnitOfMeas) { }
//                 column(Reason_Code; Reason_Code) { }
//                 column(costfromYL; costfromYL) { }
//                 column(costfromER; costfromER) { }
//                 column(costfromGBE; costfromGBE) { }
//                 column(totalcost; totalcost) { }

//                 trigger OnPreDataItem()
//                 var
//                     PeriodFilter: Text[2048];
//                 begin
//                     if (StartDate <> 0D) or (EndDate <> 0D) then begin
//                         PeriodFilter := BuildValuationPeriodFilter(StartDate, EndDate);
//                         if PeriodFilter = '' then begin
//                             CurrReport.Break();
//                             exit;
//                         end;

//                         SetFilter("Valuation Period", PeriodFilter);
//                     end;
//                 end;

//                 trigger OnAfterGetRecord()
//                 var
//                     ItemRec: Record Item;
//                     LocationRec: Record Location;
//                     CostingPeriodRec: Record "Costing Period RCGRBASE";
//                     PeriodStartDate: Date;
//                     PeriodEndDate: Date;
//                 begin
//                     Clear(Quantity_from_transfer);
//                     Clear(Quantity_from_transfer_exp);
//                     Clear(Quantity_from_prev_period);
//                     Clear(Quantity_from_purch);
//                     Clear(Quantity_from_purch_exp);
//                     Clear(Quantity_from_cons);
//                     Clear(Quantity_from_census);
//                     Clear(Quantity_from_prod);
//                     Clear(Quantity_from_sale);
//                     Clear(Quantity_from_sale_exp);
//                     Clear(Quantity_from_other_pos);
//                     Clear(Quantity_from_other_neg);
//                     Clear(Amount_from_transfer);
//                     Clear(Amount_from_prev_period);
//                     Clear(Amount_from_purch);
//                     Clear(Amount_from_purch_exp);
//                     Clear(Amount_from_cons);
//                     Clear(Amount_from_census);
//                     Clear(Amount_from_prod);
//                     Clear(Amount_from_sale);
//                     Clear(Amount_from_sale_exp);
//                     Clear(Amount_from_other_pos);
//                     Clear(Amount_from_other_neg);
//                     Clear(Cost_from_sale);
//                     Clear(Cost_from_sale_exp);
//                     Clear(costfromYL);
//                     Clear(costfromER);
//                     Clear(costfromGBE);
//                     Clear(totalcost);
//                     Clear(GlobalDimension1Code);
//                     Clear(GlobalDimension2Code);
//                     Clear(GenProdPostingGroup);
//                     Clear(ExternalDocumentNo);
//                     Clear(SourceNo);
//                     Clear(SourcePostingGroup);
//                     Clear(Document_No_);
//                     Clear(Document_Type);
//                     Clear(Tm_Name);
//                     Clear(UnitOfMeas);
//                     Clear(Reason_Code);
//                     Clear(ItemLedgerEntryType);
//                     Clear(PostingDate);

//                     HasValueEntry := true;
//                     countN += 1;

//                     if ItemRec.Get("Item No.") then begin
//                         UnitOfMeas := ItemRec."Base Unit of Measure";
//                         GenProdPostingGroup := ItemRec."Inventory Posting Group";
//                         SourceNo := ItemRec."No.";
//                         SourcePostingGroup := ItemRec."Inventory Posting Group";
//                         Tm_Name := ItemRec.Description;
//                     end;

//                     if LocationRec.Get("Location Code") then
//                         ExternalDocumentNo := LocationRec.Code;

//                     if CostingPeriodRec.Get("Valuation Period") then begin
//                         PeriodStartDate := CostingPeriodRec."Starting Date";
//                         PeriodEndDate := CostingPeriodRec."Ending Date";
//                         PostingDate := PeriodEndDate;
//                         if PostingDate = 0D then
//                             PostingDate := PeriodStartDate;
//                         Document_No_ := CostingPeriodRec.Code;
//                         Reason_Code := CostingPeriodRec.Name;
//                     end else begin
//                         PostingDate := EndDate;
//                         Document_No_ := "Valuation Period";
//                         Reason_Code := "Valuation Period";
//                     end;

//                     if (StartDate <> 0D) and (PeriodEndDate <> 0D) and (PeriodEndDate < StartDate) then begin
//                         CurrReport.Skip();
//                         exit;
//                     end;

//                     if (EndDate <> 0D) and (PeriodStartDate <> 0D) and (PeriodStartDate > EndDate) then begin
//                         CurrReport.Skip();
//                         exit;
//                     end;

//                     // Cost component mapping from Valuation Cost RCGRBASE:
//                     // 1=YLika, 2=Amesa Ergatika, 3=Fason, 4=GBE, 5=unused.
//                     costfromYL := "Cost Component 1";
//                     costfromER := "Cost Component 2";
//                     costfromGBE := "Cost Component 4";
//                     totalcost := costfromYL + costfromER + "Cost Component 3" + costfromGBE;
//                     // Valuation table has no movement quantity, so keep movement quantities at zero.
//                     // Map value once to avoid triple-counting in the existing RDLC totals.
//                     Amount_from_prod := "Valuation Cost per Unit";
//                 end;
//             }

//             trigger OnPreDataItem()
//             begin
//                 ItemCounter := 0;
//             end;

//             trigger OnAfterGetRecord()
//             begin
//                 ItemCounter += 1;
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
//             }
//         }
//     }

//     var
//         StartDate: Date;
//         EndDate: Date;
//         Quantity_from_transfer: Decimal;
//         Quantity_from_transfer_exp: Decimal;
//         Quantity_from_prev_period: Decimal;
//         Quantity_from_purch: Decimal;
//         Quantity_from_purch_exp: Decimal;
//         Quantity_from_cons: Decimal;
//         Quantity_from_census: Decimal;
//         Quantity_from_prod: Decimal;
//         Quantity_from_sale: Decimal;
//         Quantity_from_sale_exp: Decimal;
//         Quantity_from_self: Decimal;
//         Quantity_from_other_pos: Decimal;
//         Quantity_from_other_neg: Decimal;
//         Amount_from_transfer: Decimal;
//         Amount_from_prev_period: Decimal;
//         Amount_from_purch: Decimal;
//         Amount_from_purch_exp: Decimal;
//         Amount_from_cons: Decimal;
//         Amount_from_census: Decimal;
//         Amount_from_prod: Decimal;
//         Amount_from_sale: Decimal;
//         Amount_from_sale_exp: Decimal;
//         Amount_from_self: Decimal;
//         Amount_from_other_pos: Decimal;
//         Amount_from_other_neg: Decimal;
//         Cost_from_sale: Decimal;
//         Cost_from_sale_exp: Decimal;
//         countN: Integer;
//         Name: Text[100];
//         ItemCounter: Integer;
//         UnitOfMeas: Code[20];
//         loc_des: Text[100];
//         LocationFilter: Text[100];
//         GlobalDim1Filter: Text[100];
//         GlobalDim2Filter: Text[100];
//         HideItemsWithoutValueEntries: Boolean;
//         HasValueEntry: Boolean;
//         zoneCode: Code[10];
//         costfromYL: Decimal;
//         costfromER: Decimal;
//         costfromGBE: Decimal;
//         totalcost: Decimal;
//         PostingDate: Date;
//         ItemLedgerEntryType: Text[30];
//         InvoicedQuantity: Decimal;
//         ItemLedgerEntryQuantity: Decimal;
//         GlobalDimension1Code: Code[20];
//         GlobalDimension2Code: Code[20];
//         GenProdPostingGroup: Code[20];
//         ExternalDocumentNo: Code[35];
//         SourceNo: Code[20];
//         SourcePostingGroup: Code[20];
//         Document_No_: Code[20];
//         Document_Type: Text[30];
//         Tm_Name: Text[100];
//         Reason_Code: Code[20];
//         Item_Category_1: Text[50];
//         Item_Category_2: Text[50];
//         Item_Category_3: Text[50];
//         Item_Category_4: Text[50];
//         Item_Category_5: Text[50];

//     local procedure BuildValuationPeriodFilter(FilterStartDate: Date; FilterEndDate: Date): Text[2048]
//     var
//         CostingPeriod: Record "Costing Period RCGRBASE";
//         PeriodFilter: Text[2048];
//         Separator: Text[1];
//     begin
//         if (FilterStartDate = 0D) and (FilterEndDate = 0D) then
//             exit('');

//         CostingPeriod.Reset();
//         if FilterStartDate <> 0D then
//             CostingPeriod.SetFilter("Ending Date", '>=%1', FilterStartDate);
//         if FilterEndDate <> 0D then
//             CostingPeriod.SetFilter("Starting Date", '<=%1', FilterEndDate);

//         if CostingPeriod.FindSet() then
//             repeat
//                 if PeriodFilter <> '' then
//                     Separator := '|'
//                 else
//                     Separator := '';

//                 PeriodFilter += Separator + CostingPeriod.Code;
//             until CostingPeriod.Next() = 0;

//         exit(PeriodFilter);
//     end;

// }