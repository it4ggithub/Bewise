tableextension 67101 "BW Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(67100; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            FieldClass = FlowField;
            CalcFormula = lookup("Item"."Inventory Posting Group" WHERE("No." = FIELD("Item No.")));
        }
        // field(67001; "ESIL Only Value"; Boolean)
        // {
        //     Caption = 'ESIL Only Value';
        //     FieldClass = FlowField;
        //     CalcFormula = lookup("Item"."ESIL Only Value" WHERE("No." = FIELD("Item No.")));
        // }
    }
}
