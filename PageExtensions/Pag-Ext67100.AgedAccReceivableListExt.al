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
}
