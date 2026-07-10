tableextension 67101 "Customer Ext BW" extends Customer
{
    fields
    {
        field(67101; "Insurance Category Description"; Text[80])
        {
            CaptionML = ENU = 'Insurance Category Description', ELL = 'Περιγραφή Κατηγορίας Ασφάλισης';
            FieldClass = FlowField;
            CalcFormula = Lookup("CP Help Table"."Field DESCR" WHERE("Field ID" = FIELD("Insurance Category")));
            Editable = false;
        }
    }
}
