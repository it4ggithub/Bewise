table 67105 "Warehouse TB Summary Buffer"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
        }
        field(2; "Location Code"; Code[10])
        {
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; "Item Ledger Entry Type"; Text[30])
        {
        }
        field(5; "Invoiced Quantity"; Decimal)
        {
        }
        field(6; "Item Ledger Entry Quantity"; Decimal)
        {
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
        }
        field(8; "Global Dimension 2 Code"; Code[20])
        {
        }
        field(9; "Gen. Prod. Posting Group"; Code[20])
        {
        }
        field(10; "External Document No."; Text[35])
        {
        }
        field(11; "Source No."; Code[20])
        {
        }
        field(12; "Source Posting Group"; Code[20])
        {
        }
        field(13; "Has Value Entry"; Boolean)
        {
        }
        field(14; "Amount from purch"; Decimal)
        {
        }
        field(15; "Amount from purch exp"; Decimal)
        {
        }
        field(16; "Amount from sale"; Decimal)
        {
        }
        field(17; "Amount from sale exp"; Decimal)
        {
        }
        field(18; "Cost from sale"; Decimal)
        {
        }
        field(19; "Cost from sale exp"; Decimal)
        {
        }
        field(20; "Amount from cons"; Decimal)
        {
        }
        field(21; "Amount from prod"; Decimal)
        {
        }
        field(22; "Amount from other neg"; Decimal)
        {
        }
        field(23; "Amount from other pos"; Decimal)
        {
        }
        field(24; "Quantity from purch"; Decimal)
        {
        }
        field(25; "Quantity from purch exp"; Decimal)
        {
        }
        field(26; "Quantity from sale"; Decimal)
        {
        }
        field(27; "Quantity from sale exp"; Decimal)
        {
        }
        field(28; "Quantity from prod"; Decimal)
        {
        }
        field(29; "Quantity from cons"; Decimal)
        {
        }
        field(30; "Quantity from census"; Decimal)
        {
        }
        field(31; "Quantity from other pos"; Decimal)
        {
        }
        field(32; "Quantity from other neg"; Decimal)
        {
        }
        field(33; "Count N"; Integer)
        {
        }
        field(34; "Quantity from transfer"; Decimal)
        {
        }
        field(35; "Quantity from transfer exp"; Decimal)
        {
        }
        field(36; "Amount from transfer"; Decimal)
        {
        }
        field(37; "Amount from census"; Decimal)
        {
        }
        field(38; "Quantity from prev period"; Decimal)
        {
        }
        field(39; "Amount from prev period"; Decimal)
        {
        }
        field(40; "Quantity from self"; Decimal)
        {
        }
        field(41; "Amount from self"; Decimal)
        {
        }
        field(42; "Document No."; Code[20])
        {
        }
        field(43; "Document Type"; Text[30])
        {
        }
        field(44; "Source Name"; Text[100])
        {
        }
        field(45; "Unit of Measure"; Code[20])
        {
        }
        field(46; "Reason Code"; Code[10])
        {
        }
        field(47; "Cost from YL"; Decimal)
        {
        }
        field(48; "Cost from ER"; Decimal)
        {
        }
        field(49; "Cost from GBE"; Decimal)
        {
        }
        field(50; "Total Cost"; Decimal)
        {
        }
        field(51; "Valuation Cost per Unit"; Decimal)
        {
        }
        field(52; "End Quantity"; Decimal)
        {
        }
        field(53; "End Value"; Decimal)
        {
        }
    }

    keys
    {
        key(PK; "Item No.", "Location Code", "Source Name")
        {
            Clustered = true;
        }
    }
}
