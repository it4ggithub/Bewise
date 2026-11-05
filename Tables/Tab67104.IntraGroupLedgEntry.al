// Temporary buffer for report 67101 "Intra-Group Entries".
// Both the customer and the vendor branch write into this table, which lets the report
// expose a single set of dataset columns instead of a Cust./Vend. pair - a report dataset
// does not allow two data items to declare a column with the same name.
// Field names that also exist on Cust. Ledger Entry / Vendor Ledger Entry are copied with
// TransferFields, so they must stay identical to those tables.
table 67104 "Intra-Group Ledg. Entry"
{
    Caption = 'Intra-Group Ledger Entry';
    TableType = Temporary;

    fields
    {
        field(1; "Account No."; Code[20])
        {
            Caption = 'Account No.';
        }
        field(2; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Transaction Type';
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(9; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(11; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(13; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
        }
        field(14; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
        }
        field(15; "Open"; Boolean)
        {
            Caption = 'Open';
        }
        field(16; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(17; "Line Type"; Text[50])
        {
            Caption = 'Line Type';
        }
        field(18; "Line Description"; Text[250])
        {
            Caption = 'Line Description';
        }
        field(19; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
        }
        field(20; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(21; "Item Type"; Text[50])
        {
            Caption = 'Item Type';
        }
    }
    keys
    {
        key(PK; "Sequence No.")
        {
            Clustered = true;
        }
    }
}
