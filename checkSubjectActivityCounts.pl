
use strict;
use Data::Dumper;

run( "test" );
run( "train" );

sub run {
my ($set) = @_;

    print  "DataSet $set\n";

    my $subfile =  "$set\\subject_${set}.txt";
    my $subjects = loadSubjects( $subfile );
    print "Subjects\n";
    my ($totSubs,$totObs) = (0,0);
    foreach my $subject ( sort {$a <=> $b} keys %$subjects )
    {
        ++$totSubs;
        $totObs +=  $subjects->{$subject};
        print "\t$subject: $subjects->{$subject} observations\n";
    }
    print "\tTotal Subjects,$totSubs, Total observations $totObs\n";

    my $subfile = "$set\\subject_${set}.txt";
    my $actfile = "$set\\y_${set}.txt";

    my $activities = loadActivities($actfile );
    print "Activities\n";
    my ($totActs,$totActObs) = (0,0);
    foreach my $activity ( sort {$a <=> $b} keys %$activities )
    {
        ++$totActs;
        $totActObs +=  $activities->{$activity};
        print "\t$activity: $activities->{$activity} observations\n";
    }
    print "\tTotal Activities,$totActs, Total observations $totActObs\n";

    my $summary = loadCorrelations( $subfile, $actfile );
    print "Subject-Activities\n";
    my ($totCross,$totCrossObs) = (0,0);
    foreach my $pair ( 
        sort {
               my ($a1,$a2) = split('-',$a);
               my ($b1,$b2) = split('-',$b);
               if ( $a1 == $b1 )
               {
                    $a2 <=> $b2
               }
               else
               {
                    $a1 <=> $b1
               }
           } keys %$summary )
    {
        ++$totCross;
        $totCrossObs +=  $summary->{$pair};
        print "\t$pair: $summary->{$pair} observations\n";
    }
    print "\tTotal sub/act pair,$totCross, Total observations $totCrossObs\n";


    #$fileName = "$set\\X_${set}.txt";
    #die("Could not locate $fileName\n") unless -f $fileName;
}

sub loadCorrelations {
    
    my %crossCount;

    open SUBS, $_[0];
    my @subs = map {
        chomp;
        $_
    } <SUBS>;

    open ACTS, $_[1];
    my @acts = map {
        chomp;
        $_
    } <ACTS>;

    die ( "subject and activity count mismatched\n" ) unless scalar(@subs) == scalar( @acts );

    foreach my $sub ( @subs )
    {
        my $act = shift @acts;
        ++$crossCount{ "$sub-$act" };
    }
    \%crossCount;
}

sub loadSubjects {
my($fileName) = @_;

    die("Could not locate $fileName\n") unless -f $fileName;
    my %subjects;
    open IN,$fileName;
    my $last;
    my %changed;
    while (<IN> )
    {
        chomp;
        my ($subject) = /^(\d+)\s*$/;
        die( "Unexpected line ($_) in $fileName\n" ) unless $subject > 0;

        ++$subjects{$subject};
    }
    \%subjects;
}

sub loadActivities {
my($fileName) = @_;

    die("Could not locate $fileName\n") unless -f $fileName;
    my %subjects;
    open IN,$fileName;
    my $last;
    my %changed;
    while (<IN> )
    {
        chomp;
        my ($subject) = /^(\d+)\s*$/;
        die( "Unexpected line ($_) in $fileName\n" ) unless $subject > 0;

        ++$subjects{$subject};
    }
    \%subjects;
}

