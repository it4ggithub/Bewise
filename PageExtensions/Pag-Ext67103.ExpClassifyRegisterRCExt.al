pageextension 67103 "Exp.Classify Register RC Ext" extends "Exp.Classify Register RCmyData"
{
    layout
    {
        addafter("VAT Exemption Category")
        {
            field("Attach To Line No."; Rec."Attach To Line No.")
            {
                ApplicationArea = All;
                Caption = 'Attach To Line No.';
                ToolTip = 'Specifies the line number to which the attachment should be linked.';
            }
        }
    }
}
