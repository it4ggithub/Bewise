tableextension 67100 "Sort Table RCGRBASE Ext" extends "Sort Table RCGRBASE"
{
    fields
    {
        field(67100; "Insurance Category"; Text[80])
        {
            CaptionML = ENU = 'Insurance Category', ELL = 'Κατηγορία Ασφάλισης';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    trigger OnAfterInsert()
    begin

        // Calculate the Open Payments (ΑΝΟΙΧΤΕΣ ΠΛΗΡΩΜΕΣ-ΠΙΣΤΩΤΙΚΑ) based on whether there is a negative balance (Dec04 - ΥΠΟΛΟΙΠΟ)
        // If there is a negative balance, then the Open Payments (Dec13) will be equal to the negative balance (Dec04)
        // In addition, the Day subtotals (Υποσύνολα ημερών) should be set to 0 if the balance is negative
        Rec.Dec13 := 0;
        if Rec.Dec04 < 0 then begin
            Rec.Dec13 := Rec.Dec04;

            // Dec06 = 0-90
            Rec.Dec06 := 0;
            // Dec07 = 91-180
            Rec.Dec07 := 0;
            // Dec08 = 181-270
            Rec.Dec08 := 0;
            // Dec09 = 271-360
            Rec.Dec09 := 0;
            // Dec10 = 361-450
            Rec.Dec10 := 0;
            // Dec11 = 451+
            Rec.Dec11 := 0;
            // Dec12 = Total
            Rec.Dec12 := 0;
        end

        // If the balance is 0, then all should be 0
        else if Rec.Dec04 = 0 then begin
            Rec.Dec06 := 0;
            Rec.Dec07 := 0;
            Rec.Dec08 := 0;
            Rec.Dec09 := 0;
            Rec.Dec10 := 0;
            Rec.Dec11 := 0;
            Rec.Dec12 := 0;
            Rec.Dec13 := 0;
        end
        //TODO: Check what we do if the balance is positive (how we calculate Dec06-11, Dec12 should be the total of Dec06-11)
        else begin

            Rec.Dec12 := Rec.Dec06 + Rec.Dec07 + Rec.Dec08 + Rec.Dec09 + Rec.Dec10 + Rec.Dec11;
        end;

        // Calculate the total. It should be equal to either the total of the Day subtotals (Dec12) or the Open Payments (Dec13)
        // And since it's either one or the other (one of them should always be 0), we can just add them together to get the total
        Rec.Dec14 := Rec.Dec12 + Rec.Dec13;

        Rec.Modify();
    end;
}
