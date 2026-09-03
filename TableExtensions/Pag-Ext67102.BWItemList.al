pageextension 67102 "BW Item List" extends "Item List"
{
    layout
    {
        addafter("Eshop Id")
        {
            field("ESIL Only Value"; Rec."ESIL Only Value")
            {
                ApplicationArea = All;
                Caption = 'ESIL Only Value';
            }
        }
    }
}
