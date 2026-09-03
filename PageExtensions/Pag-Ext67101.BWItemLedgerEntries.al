pageextension 67101 "BW Item Ledger Entries" extends "Item Ledger Entries"
{

    layout
    {
        addafter(Description)
        {
            field("Inventory Posting Group"; Rec."Inventory Posting Group")
            {
                ApplicationArea = All;
                Caption = 'Inventory Posting Group';
            }
        }
        addlast(Control1)
        {
            field("Import File ID"; Rec."Import File ID RCGRBASE")
            {
                ApplicationArea = All;
                Caption = 'Import File ID';
            }
        }
    }
}
