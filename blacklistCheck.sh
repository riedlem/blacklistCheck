#!/usr/bin/env bash
#Author: Matthew Riedle
#Version: 1.0
#Based on Intellex blcheck - https://github.com/IntellexApps/blcheck

##### VARIABLE DEFINING #####
# The script needs to be executed as ./blcheck.sh blcheckLookup.txt
# blcheckLookup.txt needs to contain a list of IPs / domains separated on new lines
blcheckFile=$1
blcheckResults=blacklistCheckResults.txt
blcheckCount=1

# Config {


    # How many tries and for how long to wait for DNS queries
    CONF_DNS_TRIES=2
    CONF_DNS_DURATION=3

    # Blacklists to check
    CONF_BLACKLISTS="
        0spam-killlist.fusionzero.com
        0spam.fusionzero.com
        access.redhawk.org
        all.rbl.jp
        all.spam-rbl.fr
        all.spamrats.com
        aspews.ext.sorbs.net
        b.barracudacentral.org
        backscatter.spameatingmonkey.net
        badnets.spameatingmonkey.net
        bb.barracudacentral.org
        bl.drmx.org
        bl.konstant.no
        bl.nszones.com
        bl.spamcannibal.org
        bl.spameatingmonkey.net
        bl.spamstinks.com
        black.junkemailfilter.com
        blackholes.five-ten-sg.com
        blacklist.sci.kun.nl
        blacklist.woody.ch
        bogons.cymru.com
        bsb.empty.us
        bsb.spamlookup.net
        cart00ney.surriel.com
        cbl.abuseat.org
        cbl.anti-spam.org.cn
        cblless.anti-spam.org.cn
        cblplus.anti-spam.org.cn
        cdl.anti-spam.org.cn
        cidr.bl.mcafee.com
        combined.rbl.msrbl.net
        db.wpbl.info
        dev.null.dk
        dialups.visi.com
        dnsbl-0.uceprotect.net
        dnsbl-1.uceprotect.net
        dnsbl-2.uceprotect.net
        dnsbl-3.uceprotect.net
        dnsbl.anticaptcha.net
        dnsbl.aspnet.hu
        dnsbl.inps.de
        dnsbl.justspam.org
        dnsbl.kempt.net
        dnsbl.madavi.de
        dnsbl.rizon.net
        dnsbl.rv-soft.info
        dnsbl.rymsho.ru
        dnsbl.sorbs.net
        dnsbl.zapbl.net
        dnsrbl.swinog.ch
        dul.pacifier.net
        dyn.nszones.com
        dyna.spamrats.com
        fnrbl.fast.net
        fresh.spameatingmonkey.net
        hostkarma.junkemailfilter.com
        images.rbl.msrbl.net
        ips.backscatterer.org
        ix.dnsbl.manitu.net
        korea.services.net
        l2.bbfh.ext.sorbs.net
        l3.bbfh.ext.sorbs.net
        l4.bbfh.ext.sorbs.net
        list.bbfh.org
        list.blogspambl.com
        mail-abuse.blacklist.jippg.org
        netbl.spameatingmonkey.net
        netscan.rbl.blockedservers.com
        no-more-funn.moensted.dk
        noptr.spamrats.com
        orvedb.aupads.org
        pbl.spamhaus.org
        phishing.rbl.msrbl.net
        pofon.foobar.hu
        psbl.surriel.com
        rbl.abuse.ro
        rbl.blockedservers.com
        rbl.dns-servicios.com
        rbl.efnet.org
        rbl.efnetrbl.org
        rbl.iprange.net
        rbl.schulte.org
        rbl.talkactive.net
        rbl2.triumf.ca
        rsbl.aupads.org
        sbl-xbl.spamhaus.org
        sbl.nszones.com
        sbl.spamhaus.org
        short.rbl.jp
        spam.dnsbl.anonmails.de
        spam.pedantic.org
        spam.rbl.blockedservers.com
        spam.rbl.msrbl.net
        spam.spamrats.com
        spamrbl.imp.ch
        spamsources.fabel.dk
        st.technovision.dk
        tor.dan.me.uk
        tor.dnsbl.sectoor.de
        tor.efnet.org
        torexit.dan.me.uk
        truncate.gbudb.net
        ubl.unsubscore.com
        uribl.spameatingmonkey.net
        urired.spameatingmonkey.net
        virbl.dnsbl.bit.nl
        virus.rbl.jp
        virus.rbl.msrbl.net
        vote.drbl.caravan.ru
        vote.drbl.gremlin.ru
        web.rbl.msrbl.net
        work.drbl.caravan.ru
        work.drbl.gremlin.ru
        wormrbl.imp.ch
        xbl.spamhaus.org
        zen.spamhaus.org"


#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ }


# Definitions {

    # Common regular expressions
    REGEX_IP='\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)'
    REGEX_DOMAIN='\([a-zA-Z0-9]\+\(-[a-zA-Z0-9]\+\)*\.\)\+[a-zA-Z]\{2,\}'
    REGEX_TDL='\([a-zA-Z0-9]\+\(-[a-zA-Z0-9]\+\)*\.\)[a-zA-Z]\{2,\}$'

    # Colors
    if [[ $- == *i* ]]; then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        CLEAR=$(tput sgr0)
    else
        RED=$(tput -T xterm setaf 1)
        GREEN=$(tput -T xterm setaf 2)
        YELLOW=$(tput -T xterm setaf 3)
        CLEAR=$(tput -T xterm sgr0)
    fi

    # Define spinner
    SPINNER="-\|/"
    #SPINNER=".oO@*"
    #SPINNER="▉▊▋▌▍▎▏▎▍▌▋▊▉"
    #SPINNER="←↖↑↗→↘↓↙"
    #SPINNER="▁▂▃▄▅▆▇█▇▆▅▄▃▁"
    #SPINNER="▖▘▝▗"
    #SPINNER="┤┘┴└├┌┬┐"
    #SPINNER="◢◣◤◥"
    #SPINNER="◰◳◲◱"
    #SPINNER="◴◷◶◵"
    #SPINNER="◐◓◑◒"


#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ }


# Macros {

    # Verbose printing
    VERBOSE=0
    info() {
        if [ $VERBOSE -ge "$1" ]; then
            echo "$2"
        fi
    }

    # Error handling
    error() {
        echo "ERROR: $1" >&2
        exit 2
    }

    # Show progress
    progress() {

        # Bar
        x=$(($1 % ${#SPINNER} + 1))
        BAR=$(echo $SPINNER | awk "{ print substr(\$0, ${x}, 1) }")
        if test -z "$PLAIN"; then
            printf "\r ";
        fi

        # BAR as printf arg so that backslash will be litteraly interpreted
        printf "[ %s %3s%% ] checking... %4s / $2  " "$BAR" $(($1 * 100 / $2)) "$1";
    }

    # Resolve the IP
    resolve() {

        # IP already?
        IP=$(echo "$1" | grep "^$REGEX_IP$")
        if [ "$IP" ]; then
            echo "$IP"

        # Resolve domain
        else

            # Handle special resolve types
            case "$2" in
                "ns" ) TYPE="ns"; REGEX="$REGEX_DOMAIN\.$";;
                   * ) TYPE="a";  REGEX="$REGEX_IP$";;
            esac

            case "$CMD" in
                $CMD_DIG ) "$CMD" $DNSSERVER +short -t "$TYPE" +time=$CONF_DNS_DURATION +tries=$CONF_DNS_TRIES "$1" | grep -om 1 "$REGEX";;
                $CMD_HOST ) "$CMD" -t "$TYPE" -W $CONF_DNS_DURATION -R $CONF_DNS_TRIES "$1" $DNSSERVER | tail -n1 | grep -om 1 "$REGEX";;
            esac
        fi
    }

    # Load the blacklist from file
    loadBlacklists() {

        # Make sure the file is readable
        if [ ! "$1" ]; then
            error "Option -l requires an additional parameter";
        elif [ ! -r $1 ]; then
            error "File $1 cannot be opened for reading, make sure it exists and that you have appropriate privileges"
        fi

        CONF_BLACKLISTS=$(cat "$1")
    }

    # Show help
    showHelp() {
        cat <<HELP
blcheck [options] <domain_or_IP>

Supplied domain must be full qualified domain name.
If the IP is supplied, the PTR check cannot be executed and will be skipped.

-d dnshost  Use host as DNS server to make lookups
-l file     Load blacklists from file, separated by space or new line
-c          Warn if the top level domain of the blacklist has expired
-v          Verbose mode, can be used multiple times (up to -vvv)
-q          Quiet modem with absolutely no output (useful for scripts)
-p          Plain text output (no coloring, no interactive status)
-h          The help you are just reading

Result of the script is the number of blacklisted entries. So if the supplied
IP is not blacklisted on any of the servers the result is 0.

HELP
        exit;
    }

#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ }

# Loading the list of IPs / domains into a list
	IFS=$'\n' read -d '' -r -a list < $blcheckFile

	echo "Blacklist Check is starting."
	echo "Number of search terms loaded for lookup: " ${#list[@]}
		
	for line in ${list[@]}; do

# Echo the current line number
		echo "Entry #"$blcheckCount" -- "$line
	
# Add spacers to the beginning of the results
		echo "==========" >> $blcheckResults

# Reset the timestamp to the current time and use PST
		timestamp=$(TZ=":America/Los_Angeles" date)
	
# Load the current time into the file to record what time the WHOIS Lookup was performed
		echo -e "Lookup was performed at $timestamp" >> $blcheckResults

# Add the search term being queried
		echo "Lookup was performed on $line" >> $blcheckResults
		echo "" >> $blcheckResults

# Parse the params
while getopts :vqphcl:d: arg; do
    case "$arg" in
        d) DNSSERVER=$OPTARG;;
        l) loadBlacklists $OPTARG;;
        c) VERIFY_BL=TRUE;;
        v) VERBOSE=$(( (VERBOSE + 1) % 4));;
        q) VERBOSE=-1;;
        p) PLAIN=1 RED="" GREEN="" YELLOW="" CLEAR="" ;;
        h) showHelp;;
        ?) error "Unknown option $OPTARG";;
    esac
done
shift $((OPTIND - 1))

# Get the domain
if [ $# -eq 0 ]; then
    echo "Missing target domain or IP."
    showHelp
fi
TARGET=$line

# Some shells disable parsing backslash in echo statements by default
# Set the flag to enable echo to behave consistently across platforms
shopt -s xpg_echo

# Get the command we will use: dig or host
CMD_DIG=$(which dig)
CMD_HOST=$(which host)
if [ "$CMD_DIG" ]; then
    if [[ $DNSSERVER ]]; then
        DNSSERVER="@$DNSSERVER"
    fi
    CMD=$CMD_DIG
elif [ "$CMD_HOST" ]; then
    CMD=$CMD_HOST
fi
if [ ! "$CMD" ]; then
    error "Either dig or host command is required."
fi
info 3 "Using $CMD to reslove DNS queries"

# Parse IP
IP=$(resolve "$TARGET")
if [ ! "$IP" ]; then
    error "No DNS record found for $TARGET"
elif [ "$IP" != "$TARGET" ]; then
    DOMAIN=$TARGET
    info 2 "Using $TARGET for target, resolved to $IP"
else
    info 3 "Using $TARGET for target"
fi

# Reverse the IP
REVERSED=$(echo "$IP" | sed -ne "s~^$REGEX_IP$~\4.\3.\2.\1~p")
info 3 "Using $REVERSED for reversed IP"

# Get the PTR
info 3 "Checking the PTR record"
case "$CMD" in
    $CMD_DIG ) PTR=$("$CMD" $DNSSERVER +short -x "$IP" | sed s/\.$//);;
    $CMD_HOST ) PTR=$("$CMD" "$IP" $DNSSERVER | tail -n1 | grep -o '[^ ]\+$' | sed s/\.$//)
esac

# Validate PTR
if [ ! "$PTR" ]; then
    info 0 "${YELLOW}Warning: PTR lookup failed${CLEAR}"

else

    # Match against supplied domain
    info 1 "PTR resolves to $PTR"
    if [ "$DOMAIN" ]; then
        if [ "$DOMAIN" != "$PTR" ]; then
            info 0 "${YELLOW}Warning: PTR record does not match supplied domain: $TARGET != $PTR${CLEAR}"
        else
            info 1 "${GREEN}PTR record matches supplied domain $PTR${CLEAR}"
        fi
    fi
fi

# Filter out the blacklists
BLACKLISTS=""
for BL in $CONF_BLACKLISTS; do
    if [ "$BL" ]; then

        # Make sure the domain is a proper one
        DOMAIN=$(echo "$BL" | sed -e 's/^[ \t]*//' | grep ^"$REGEX_DOMAIN"$)
        if [ ! "$DOMAIN" ]; then
            info 0 "${YELLOW}Warning: blacklist '$BL' is not valid and will be ignored${CLEAR}"

        else

            # It is a proper blacklist
            if [ "$BLACKLISTS" ]; then
                BLACKLISTS=$(echo "$BLACKLISTS\n$DOMAIN")
            else
                BLACKLISTS="$BL"
            fi
        fi
    fi
done

# Make sure we have at least one blacklist
COUNT=$(($(echo "$BLACKLISTS" | wc -l)))
if [ ! "$BLACKLISTS" ] || [ "$COUNT" -eq 0 ]; then
    error "No blacklists have been specified"
fi
info 1 "Matching against $COUNT blacklists"

# Initialize the counters
INVALID=0
PASSED=0
FAILED=0

# Interate over all blacklists
I=0;
for BL in $BLACKLISTS; do
    PREFIX=
    I=$((I + 1))

    # What should we test
    TEST="$REVERSED.$BL."

    # Make sure the info is shown if we are cheking the servers
    if [ "$VERIFY_BL" ] && [ $VERBOSE -lt 1 ]; then
        VERBOSE=1
    fi

    # For verbose output
    if [ $VERBOSE -ge 1 ]; then

        # Show percentage
        STATUS=$(printf " %3s" $((I * 100 / COUNT)))
        STATUS="$STATUS%% "

        # Show additional info
        if [ $VERBOSE -ge 3 ]; then
            PREFIX=$(printf "%-60s" "$TEST")
        else
            PREFIX=$(printf "%-50s" "$BL")
        fi

        PREFIX="$STATUS $PREFIX"
        if test -z "$PLAIN"; then
            printf "%s \b" "$PREFIX"
        fi

    elif [ $VERBOSE -ge 0 ]; then
        if test -z "$PLAIN"; then
            progress "$I" "$COUNT"
        fi
    fi

    # Get the status
    RESPONSE=$(resolve "$TEST")
    START=$(echo "$RESPONSE" | cut -c1-4)

    # Not blacklisted
    if [ ! "$RESPONSE" ]; then

        # Make sure the server is viable
        ERROR=""
        if [ "$VERIFY_BL" ]; then
            TDL=$(echo "$BL" | grep -om 1 '\([a-zA-Z0-9]\+\(-[a-zA-Z0-9]\+\)*\.\)[a-zA-Z]\{2,\}$')
            if [ ! "$(resolve "$TDL" ns)" ]; then
                if test -z "$PLAIN"; then printf "\r"; fi
                printf "%s%sUnreachable server%s\n" "$YELLOW" "$PREFIX" "$CLEAR";
                INVALID=$((INVALID + 1))
                ERROR=TRUE
            fi
        fi

        if [ ! "$ERROR" ]; then
            if [ "$VERIFY_BL" ] || [ $VERBOSE -ge 1 ]; then
                if test -z "$PLAIN"; then printf "\r"; fi
                printf "%s%s✓%s\n" "$CLEAR" "$PREFIX" "$CLEAR";
            fi
            PASSED=$((PASSED + 1))
        fi;

    # Invalid response
    elif [ "$START" != "127."  ]; then
        if [ $VERBOSE -ge 1 ]; then
            if test -z "$PLAIN"; then printf "\r"; fi
            printf "%s%sinvalid response (%s)%s\n" "$YELLOW" "$PREFIX" "$RESPONSE" "$CLEAR";
        fi;
        INVALID=$((INVALID + 1))

    # Blacklisted
    else
        if [ $VERBOSE -ge 1 ]; then
            if test -z "$PLAIN"; then printf "\r"; fi
#            printf "%s%sblacklisted (%s)%s\n" "$RED" "$PREFIX" "$RESPONSE" "$CLEAR";
        elif [ $VERBOSE -ge 0 ]; then
            if test -z "$PLAIN"; then printf "\r                                                          "; printf "\r"; fi
#            printf "%s%s%s : %s\n" "$RED" "$BL" "$CLEAR" "$RESPONSE"
        fi
        FAILED=$((FAILED + 1))
    fi
done

# Print results
if [ $VERBOSE -ge 0 ]; then
    if test -z "$PLAIN"; then
        printf "\r                                                    \n"
    else
        printf "                                                     \n"
    fi
    echo "----------------------------------------------------------"
#    echo Results for "$TARGET"
#    echo
#    printf "%-15s" "Tested:";   echo "${COUNT}"
#    printf "%-15s" "Passed:";   echo "${GREEN}${PASSED}${CLEAR}"
#    printf "%-15s" "Invalid:";  echo "${YELLOW}${INVALID}${CLEAR}"
    echo "$TARGET found on ${RED}${FAILED}${CLEAR} Blacklisted sites"
	echo "$TARGET" ":" "${FAILED}" >> $blcheckResults

    echo "----------------------------------------------------------"
fi

# Add spacing
		echo "" >> $blcheckResults
		echo "==========" >> $blcheckResults
		echo "" >> $blcheckResults
		echo "" >> $blcheckResults
		
		echo ""

# Increment the counter
		(( blcheckCount++ ))


done

echo ""
echo "Script has finished."

exit $FAILED;