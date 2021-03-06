# generate prototypes for rsync

$old_protos = '';
if (open(IN, 'proto.h')) {
    $old_protos = join('', <IN>);
    close IN;
}

%FN_MAP = (
    BOOL => 'BOOL ',
    CHAR => 'char ',
    INTEGER => 'int ',
    STRING => 'char *',
);

$inheader = 0;
$protos = qq|/* This file is automatically generated with "make proto". DO NOT EDIT */\n\n|;

while (<>) {
    if ($inheader) {
	if (/[)][ \t]*$/) {
	    $inheader = 0;
	    s/$/;/;
	}
	$protos .= $_;
    } elsif (/^FN_(LOCAL|GLOBAL)_([^(]+)\(([^,()]+)/) {
	$ret = $FN_MAP{$2};
	$func = $3;
	$arg = $1 eq 'LOCAL' ? 'int module_id' : 'void';
	$protos .= "$ret$func($arg);\n";
    } elsif (/^static|^extern/ || /[;]/ || !/^[A-Za-z][A-Za-z0-9_]* /) {
	;
    } elsif (/[(].*[)][ \t]*$/) {
	s/$/;/;
	$protos .= $_;
    } elsif (/[(]/) {
	$inheader = 1;
	$protos .= $_;
    }
}

if ($old_protos ne $protos) {
    open(OUT, '>proto.h') or die $!;
    print OUT $protos;
    close OUT;
}

open(OUT, '>proto.h-tstamp') and close OUT;
