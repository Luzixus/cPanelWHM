#!/bin/sh
# This script was generated using Makeself 2.1.3
INSTALLER_VERSION=v00107
REVISION=19e129efd75d93f8e0c72bcd3e3eee84c6fb291d

CRCsum="1687274707"
MD5="dd295020e5f7ef3f11145b13bb675ba9"
TMPROOT=${TMPDIR:=/home/cPanelInstall}

label="cPanel & WHM Installer"
script="./bootstrap"
scriptargs=""
targetdir="installd"
filesizes="26182"
keep=n

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if ! type "tar" &> /dev/null; then
    yum -y install tar
fi

if ! type "tar" &> /dev/null; then
    echo "tar must be installed before proceeding!"
    exit 1;
fi

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_Progress()
{
    while read a; do
	MS_Printf .
    done
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.1.3
 1) Getting help or info about $0 :
  $0 --help    Print this message
  $0 --info    Print embedded info : title, default target directory, embedded script ...
  $0 --version Display the installer version
  $0 --lsm     Print embedded lsm entry (or no LSM)
  $0 --list    Print the list of files in the archive
  $0 --check   Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --target NewDirectory Extract in NewDirectory
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --force               Force to install cPanel on a non recommended configuration
  --skip-cloudlinux     Skip the automatic convert to CloudLinux even if licensed
  --skipapache          Skip the Apache installation process
  --skipreposetup       Skip the installation of EasyApache 4 YUM repos
			Useful if you have custom EasyApache repos
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH=$PATH
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
    MD5_PATH=`exec 2>&-; which md5sum || type md5sum`
    MD5_PATH=${MD5_PATH:-`exec 2>&-; which md5 || type md5`}
    PATH=$OLD_PATH
    MS_Printf "Verifying archive integrity..."
    offset=`head -n 412 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
	crc=`echo $CRCsum | cut -d" " -f$i`
	if test -x "$MD5_PATH"; then
	    md5=`echo $MD5 | cut -d" " -f$i`
	    if test $md5 = "00000000000000000000000000000000"; then
		test x$verb = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
	    else
		md5sum=`MS_dd "$1" $offset $s | "$MD5_PATH" | cut -b-32`;
		if test "$md5sum" != "$md5"; then
		    echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
		    exit 2
		else
		    test x$verb = xy && MS_Printf " MD5 checksums are OK." >&2
		fi
		crc="0000000000"; verb=n
	    fi
	fi
	if test $crc = "0000000000"; then
	    test x$verb = xy && echo " $1 does not contain a CRC checksum." >&2
	else
	    sum1=`MS_dd "$1" $offset $s | cksum | awk '{print $1}'`
	    if test "$sum1" = "$crc"; then
		test x$verb = xy && MS_Printf " CRC checksums are OK." >&2
	    else
		echo "Error in checksums: $sum1 is different from $crc"
		exit 2;
	    fi
	fi
	i=`expr $i + 1`
	offset=`expr $offset + $s`
    done
    echo " All good."
}

UnTAR()
{
    tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
}

finish=true
xterm_loop=
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    --version)
    echo "$INSTALLER_VERSION"
    exit 0
    ;;
    --info)
    echo Installer Version: "$INSTALLER_VERSION"
    echo Installer Revision: "$REVISION"
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 108 KB
	echo Compression: gzip
	echo Date of packaging: Thu Feb 25 16:03:49 UTC 2021
	echo Built with Makeself version 2.1.3 on linux-gnu
	echo Build command was: "utils/makeself installd latest cPanel & WHM Installer ./bootstrap"
	if test x$script != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"installd\"
	echo KEEP=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=108
	echo OLDSKIP=413
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 412 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 412 "$0" | wc -c | tr -d " "`
	arg1="$2"
	if ! shift 2; then
	    MS_Help
	    exit 1
	fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - $*
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
	if ! shift 2; then
	    MS_Help
	    exit 1
	fi
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --xwin)
	finish="echo Press Return to close this window...; read junk"
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--force)
	scriptargs+=" --force"
	shift
	;;
    --skip-cloudlinux)
	scriptargs+=" --skip-cloudlinux"
	shift
	;;
    --skipapache)
	scriptargs+=" --skipapache"
	shift
	;;
    --skiplicensecheck)
	scriptargs+=" --skiplicensecheck"
	shift
	;;
    --skipreposetup)
	scriptargs+=" --skipreposetup"
	shift
	;;
    --)
	shift
	;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

case "$copy" in
copy)
    SCRIPT_COPY="$TMPROOT/makeself$$"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2
    ;;
phase2)
    finish="$finish ; rm -f $0"
    ;;
esac

if test "$nox11" = "n"; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm rxvt dtterm eterm Eterm kvt konsole aterm"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test "$targetdir" = "."; then
    tmpdir="."
else
    if test "$keep" = y; then
	echo "Creating directory $targetdir" >&2
	tmpdir="$targetdir"
    else
	tmpdir="$TMPROOT/selfgz$$"
    fi
    mkdir -p $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target OtherDirectory' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x$SETUP_NOCHECK != x1; then
    MS_Check "$0"
fi
offset=`head -n 412 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 108 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

MS_Printf "Uncompressing $label"
res=3
if test "$keep" = n; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

for s in $filesizes
do
    if MS_dd "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; UnTAR x ) | MS_Progress; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
echo

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = xy; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval $script $scriptargs $*; res=$?;
		fi
    else
		eval $script $scriptargs $*; res=$?
    fi
    if test $res -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test "$keep" = n; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res

��e�7`�[�r۸��o="{#iG�.�%r�c+��vd'٩�,�"!�c����� �/w�d� 	R��L���n�*K �h4��u�~š<��>��lm�_���n��6�u7v��{����N�����u�}�O�F�س�X��=�?�Y{��^;�V*��ë���J��_�s��ھ5¶wږ#����е=��M��è�~�e�{ӈ��x��'~�;_��5�U�v��ͯ_.�A���#�����������`�K&Y�>|8����ǣ�߂��[���^���]��avČ[�v���Ғ(��Ы�ZF�����(�ԕqs�����ބ-��b�i�8�c�hi�Bg�F������(�Q�\;��N2�=��x�,�'Ә3c�"��8�|��1#)�2���R쌦Y�6���$�r%A��1�����2�BÅ��9�-�NBd�v<��S���ƗxrÊX����Vw��k4�ԟ�[��x
��?�g��M����w�p<�� �ۖo&.�b#�
ׄ�i�Q�ǘ�w^�fԖ�A�~8Nl�����j"r�ωr$�i�iOyl����3}o�Ym)W!V
a�ً��������#��-{ls�ƞJ�e*C
�l|���>y�o��X�m��I�����������U����'�٠3"}#R�˃�;8\�U��y4�������H�4.v�b�z��٠6I���*{�Ǫ�L�3�XNJ�4aL���<��G�ϲ�/N��;}�ʜ�`��pN.� 6�l�l��>X>��܂��~g~��1�]�ʭt��{lK��:�������]0>���q�����5��t�wAh{1�z~��A�{Σ�C�7�k�)�|�O�g�*Z*�����^->�c,D���&9���ӿ��<4)װ��`W�7d6����!<�n�K)�BD��0�h�t?�`�?
�̜r���OK(�cہ��9<�2�5
�U0�G6DFgΦ�g9"�%������g������s���C��cckcss��������g�/�?�0&��/�������O��Q��mu6��g��Nwkg�-����ݿ��;�!�\c2?i�������ϡ�E���t_1��7٩v�" ����(Gl�#�r	��o���41ل\3	�����)�NF�s3Ƅ��-�9�ɽ��{�H���	�9A,���O�s��1������o��
�ѐ�������"�vi��������p$�����'![w3iݤ�n����=օ�CG}<ݥ��C}88�Uﱍ��������#6o�PX2�
,J����=B�:[�'M�;��y��|�8	=����s���mK�`���|�{z��a�����=V�g2�a���`���ݭ�_94��Gj�~�]�<�x#�H^�Y|��4�������z�ݥ��gW�uV��&�2�����1��q=[[�j�ڱm�/�r\%#�����<�Q�f��e�����?ue{�G
O�8�ǃ�9N�0;>��W�.�h��o�����������D�����;�>8���R�E��,��:�]��7�N�����߅/��B��>�����(���zC��\@�ȋࣶ^q���zy��_��P[g�"�����~���>83j�f�G������������i6xo���~G�W�?g��7Ww<�8d{�͗+����f}��f���*���o������Z�����),�~���E>��'=���kx�'��_��w]VQ
mFhJ>O\�}��vD�����SixZ#'-�Ѷd�Ѡ��v7oD�p&
�<��aM��؁n��\ȚJ9b>�j�G�e��/���EAz��@FO�#���Pcu0� ���A�,����`��4��`{�	�u@)M��'X��|$~�5!�����'eۂ��ס��������S�ҟO.���Sx�������@-B�v�N��]�q c#qbvk8	��ɎY�x�7�����!����X	�opi4�������QpF�� N;��a����!	�a��w!U{������������\����Ct<
`�8�]K5F����a.n١��a>xb~<m��kp������U�����9[��a�#n)�
�Ӓ�K#A?���2U���|�(�C���TF�X��c��ލ�%� ���e1E�Faf	�Ғ-K��*�78UR�z?v���p��Q.��w�	4Vm#RY�!$�9�{���O�]��{hC���k���
�ǡK�Y���e*$�w����0<c��w��˃����>T��|��k�]OΏk@�\�aMt� �\����xP{(�z�O\#�a�^o���Zj�5�ʈN�`��V���*`zM��>hsF�Q�BI�̸�8��ؠ��)�1�9�0st+�@�>/����`i�,�+�W�hhl�SR��,���c�sρ�.0���b��̠M�@
����J���|ɞs���������l6c�����SY����U|�X�);jR�����)y`'�\��� ��a����rH�	2ۓ����������{`��ubb��͙*�B��*��#���lPVaJ���Ph/]��Ћ�Gʜr,�|���0e�56L�Z(5�Q��������]�:����k��y�!��D�z��?�iw�b�+���{�D}�zq�t�YOE�Ǝ��z��E��AJ0��w���2O��s9A=��2�l�#%ꄶt�ĺ$�.�pQ���Q�N�5���ׅ��.�݃04��L��ȣ7��5B���S�g�`U�!l�"&���KMv�����z<�F��S�D����I	�֊�s�Z �*ɮ�(@X1F�2�ﺠ�V<�I$���ñ-4�i���|���s��b�g�ɣX@�3?�i��K�,�sd�)�`O����W�8����di�b���_\����ǿ��U
�>+�R�ZΤK�r�R܎bۙ$�"o�xL�I�lqڊ�d�U/1Z��#Yݣk�!$�Z�uIo�`�C�L΀m�ĜE\�mY�c��\���;���
QE��#`W����"]r ���D;(�B�g����Ec��arUY�B�mv�#NdE_���2�M��������W���d�!��έ�j�n�x�����ɧF�IM�0p#=ۻ<�Y�\H�F��\GX��^�YeVB�8ûz����V��&�ȝǹŭl���JB%3��KX��h�PFj%�Uh����X}�x�FY&f��N���|$7�+�+R$���$�ane܌�Y��:��i��d
(4f�VS�>,������vr~M`�"&�é���`x��g��4�P�J���!&��Gs��XX-�*��Ė�5��L�*t�u��\Ϗ�(;��JÛ�1K���~:Y,U�Pac�	�����,z���6�`��+�������@�23xTkS�C�L +�#�
��B*��+#M����)����0e����Qó�D��W��@]N7��ȁ���Dئ��i���S����,���e.�ahx�a<'�7 �O����s9C�q�A'��Q����Y<d�`-�\lj=
�ǈ���AV��}p�cӋ�&%q�T��aq�ѹ����t��4�(�{'��ڡ��F�Ӄ��Ǡ���t�h�n�Ò�<sIAJ������[���N����J�2��~~�M�đ$
�T�y|Q����������a�R�������*���<	0�=I'�q{�I#;���5
��*B��BB*8��x��HE/׫�L����)���-~���{���G����j��%�ef��CJb|k�}Ȓ��eY�g�J�M܅�bD
�5�9�_��|d(wo�&WS��ji`v}���{s�c*��n�JUb�����5%���c�T�F>j��OA
"��B+IJd�h��g�T�.z�2O�.6:㾚����4��
qפ�^��\'W�S߿!����n�܄�B�N� ��v��"tN ��D�P����S�i�|jJ�$wY�*�eVS�ɚ:�ԝ����A��K�Y�G�ȕ�VAF�5̨��(���8���Z��Üg.��,+
M�[�&��c�6�����L�?	���)a��&�Gq�.�����H!Q=s��S�ʮ^���*Zj��^m�tT����(Fƀ\�<��Q�n�Y�r��T��|ݝG���!�yda3^iT�g6@�m����%�d9��up�{x����
̙��}|�	���-��슬�2C�.�I�<R���9���� �M`�K#:�.�j�KF8��)�4�C����Gв(/������2�F4u���3�׳��e�|i�t�5B���YQKEs}qt���$ݖqO�\*T�	��͓yGQ�Y���"�'١|��ZԈt9�t��3�DZx68���Z�m!���2�)��z

�%eTe1�ثaT�w<��JHc5I����P���}��J8��'��&�M�p%]+��Z�6��d-Oe9gwi_���1{�@t	���{`��@ky�IP��g���CUvR��r|�������HF�%=%+���4"�#_rҭ|�,"������s��)��[�� ����}
~nf ������!��My�Hų�$�hb�WLk��������_i�����o�� �#T��p�g!�ݡ�ŐDE�[��f�QG��j�⊉�؋eBU�81�7����X��xN��Au�j%őhj�c.���.�j��1�iZy9�t�)��=)o_	5�%w�F^�xL51N>�|w�$��%�"첢0P��4듸#�� M��~hS���\�?$�WU`L}ey��6��5��L�
Rn��Ai�]�@yu1���0�=덦�

���wB�~-/��Sv�
d*�Q�#{�R�zIIdy8ϵ�lu:M�#�;�2JIUL���w�e�*��o!ӶZ�4�Ϟ�n.�:�gXاp��PO�A�����4�O�zq.YS�F��)��m�V��.��ՃL����0�f�bS
Q\��(NC���nK,� ��f^}�i�e����^�ȿ�f;�[�x�"�蘭��Y���꽊��V`s�^l;:�x�4���V�BAV��eOJV0-��>�cꋼ�43���0�IF�I�����iܵτ�i��������CGfr��_��m�Ie6�j	J"'��
���{��:8?Oz�A����8��3�uz���%QuT�N�ӏ�ߦ2�!
���8�I,��9��5\�q����$�	4�~�RӠb<�BlR�f�&��2U�V��	B��Acx�^��`� �+]�g'c�K$��m-nZ<���оr2���Mu��>O��x8yU"�ɷ(�r,���v�����Q�]�	,H������^]n�S=��"
x�r^
:�XHТ�۝흗��W�v����5R�V�����F��S-|�.��z����վ�!:�֍
�^	X0q�C�^PW�*Rj����EWW���4\,�)�/+�)�$)W��o��\hPDy�6���j�6����[��^
M��H=���++ڐ�K�z#��x%
@.�O^��R�cƐ�Iq�tx���_�Qֲ�bp���"0�
�nӱn�M{l��m�ya��)BL�yS����y����H��En�q�f���IZ���7�_U��*.�FxwO�P��!A��9�I����"�׊����i{������s��1]K��J}��C��i����H�4�YW��D��(qI0)�f&����TN���@�D	��(�b}��ǘy��!�(}�q[����Rʥj�!�K
��}17��7}�T�To��@2�?V�_�ǃ\YlGYr�Dpw��}j2W�.4	Y8�/�u; N@y�*�A����{���46oZ��\����fd��:4zL�%~�B�|9�������A'�f5�gz�qZ-�B��tH�j�E/ฝf�l
�Y���Y]��n��w�����w	jc�Sd����,l<�~�j��z�%���?���R�?��iC��}<E��C �����F�*{����G�ܟ�'4Њ�:�lc������ٷ(zѫ^��7�S��������
f8o�l*���t�������iE���6�����F���2+;2���~�
v�Fa�, ~pg~����)�{uO�^�#�ØZW�����k#Y�VJ�]1����l�z��k��7ʿM�9���G����8�4���Vkl6�ms:��Cɱ[�貟(��'���y�
>Q��!tJ�������+6�վ�&hʲ����XV,D��X��j���y┃6�T��Cq|� ����m�rWm"H�[��ߣ�~0�ׇ��^�3uo�~yB�����f3��>�ɵB'�f�ۘ��}�i=Fa��|tT�BŻus�0�F��@m�h���NߟU%`��Ns�CM�4wFn�S�e%�����u2�~R������
9��XYkT]Q��B���!zO��ļ��Ɏ�P1`+j~�N������T��ś�h��]0yII�=����F `�.[�Mp~-0�j��EA���w>��٠�ǜ��~��*qP+�AAG�LB�R���-AZb��M�O�K�uI[O�7����)(�NUI�Y
���i�,N��������٣�7Q��ƛ2��ӂ"��O���*Κ�
0����GMbl��@�B�<7�>�������|��ӂ����i�Ĩ*�Ԅ��;�y?����]��Rt�u�V��	w�^:�	Sv:��@�]L�Q�YEL����8��K_Wi�7�h.s��P,O�_�j�J,�7�T��ņ"�YO���V�ˠ;U��E�2�&ˈ%;�8�^����R�
kY(p0)ݽ[�Qjb�t��\ -�`y��W����A�3ҹ�84	:��t~-���߃�j_��Tgz���Tm��tsh<>��bk3��:شu
��8���J>L?�G�Z��nMF��d�����IQ:Oɪ�����+�zf���Bۗ��^�!ԧ|[�=��N�xt����ט!��~�|���p�L����-j{��]xkں��|V�p���\���X��5�,��#�5�J�BU�G���G���N7�q��y4LOa��l�s+����� UW�2Y���O�	�tMp�D>��Q8lL3A�pӿWūF�Hy��hZ<R��0�B�rPR����r�B��	`�اQ]����u�Y
+O��q��X7����jqq"65���^Ikf��nl9,�՚;>0D���H�Q��T�q2��Qd��K��T\�\o���NEj��hg�n5��d%�g?$���ۛ 7f
�A�
L��O/�P�F��36�v�-�L����Q����p�
�Y��``�Y�|;4���X�����J�7�f�qۻ�efj��>{:���A؟�]q}�W�UR�i�ߣ��,>?K�=I�"'�rR&�6n8Z�Tc��4��>	�q���Ry݈�y�Z=�՛�WR���&��X�f<_��ך�#���ZA��I	�Q�wF"�^����z�,k�Ձm"U�lDON%��f'�ʲ\�e$���rL�l_�d��!}��s�Q���O�����PL}܃��5�	����2�p9^�uG$g�#�ꪅ=�?O�9�����L��]��3j4>��a���׏�h�%FtQ�n\��QI`�n|5��-��H���'�� �U#�dn!�d���:T���������"��.Z��r15����?�PL��8_R�E�4�Nt�3)������a�8g�����r�A�kI�x��ݬ�-��+v�hZ4���"F�=!�wښ��辂�Fc<G�Xmw7"(�x��޸������vHā7��v03
4��t�j���%gM3�/o`M*�i�?{ht����Տ�hh��*�h6��+⨠��7N�����mּAW:�V苫U�덪�d~-;���V��"��y��O;�9��Nͦ-=�@��`م^G��c]�q\��#}e����=�E������Td+�����%�%~㑆�S)Y�i�-������`.D���fcUX{�)��T�[��g"��
~՞�	���Zd�������V�;	���F��T�O�Suy�p���5��M�;�n�ݩ9n:i���ݒn�~�����9oy�#�P ]�{ﰯ,F�#���ҧ�$�T̝�`��X{u�cJD�`��$n�IƶB�}ޓ��{#0�`�(�v-�T59J�(Ϧ�kx�Tv��?/\��Rp=����8_ �x�K4QB�7����/���ΑO �RZ�Z
��6�z	��c�!��=�C��0��l�(Vs=��Ф�5s���LGݬ}���.(����Ɇ/��V���;Z�@L�J?�������Â:T�e�X�״:�V���˦0ם�(U���hU�$�gY�@�);@u2m�U�
��1W����f��j�a���;��Q�.o����SN�_��&�����W���+2I�i�.�][�ܵ�!vt��`�$ȰW3	jRA��!gu������k�߂lUg�^V�
���b��b&� _5���ֻ���nK#怕�YiFu"�*���*�.�Y:p`Qc�ZƐ4fL�F��w�lN#�0֦"�e�֊(P�b[*o�Cͩ���\rgKYd�:+�\�S�����ε�*�jq����f����Ղ4��^4����C��D���>]���t�Z��47,�w�c�КG$�:|�93�o`�����R)�����������Q��������o�,��1�ʿ1�R"r	�۲U�"��jpH}��[�}=z��Y��Η��Z����M+Ԍ���ݻ��ı�On�>�2��XD���p��9mB$l2��|(�
4>�����\偈D�6bl,�/�}ߏ?�L#�/-�Q'w2V/gyM��}<��DM^�7}��(2	����
�B����ϋޚ��$6K"���Uq���4��\��H"�������%O��΋F�Z)�Ai���6�3j�Yn)�xK�p���*;%ؔ.XA�Lș�̣�Op{�=�X-~���h8��4.��נsݱ6����V���M�Wƻ��Wy�)�uj�jTo�d��
��+�fԚ��ѷ�l�mo9O¾��˲����5�̺���dA�����jU�}��
���({O`�=\/3%��J�F�Y�xzŶ�P�s��y�c ���R���[�t`d��el���(>d��N9t| ]����˄u�6{�v:*�`���
Xj,�D�e���$�
F��4W;6�<#O��w���#�>��<�a5��N�+z���(�N_CC,�h��P{ٿ�%=��iE�R���WB��Ľ��m,�C��[�3���I���AU}�{���h�?������A[�1s��&�T�tdB����'�
�D��<Q��M�9G��Oj��؊�~��>�����u�E�F
�7�$K��.Ä�� e��KV/X(��!��s��B&_�.iIp4��}B[FCkD.Tz�� ��l{,M�x�~��W����d\������CRo���\�)2sQ�ϓvQKV���ެ`(	��Q|tB�htk�{�����ɛ��@o5P��6N%���Z
/��*���o�λe[�	�A����vTt�4~�tj���&Pt�b��)����c��J`�&��Z'j\�����72q<P����`�(O�[L�m���ƨɋ}��h�閦�;�"P����N���ː�%���l�r3�l�}x<ǃ��Z����Ǫa����f��V&z��[Cܶ�"��;���et��x_��e�4��/�5,������𮗥=X�&���gD�z}�7}qqI=���꿧�C��Y��m�;U�ֻ������%�e[�O�E4���`�a��'8S�����>�}v{���G��JԌ��|�a-'�mvi$Y��5P�"�V�������TMsSD�GP"�� �~�z�|W������SF�u�n����ԭ�@���ם,�b�������gV�䏇yj�]��SJf�*��-3>$9�fW�ɡ[�����,z8�VFO��Th��
��ܖ	]8٦
ӰP?�͇���ڟ�!��z��'�c�s�D����+;�@��tx�j�@[��;�Z�����9�RW�Gt�7��PA�NPJ	���Wk�]Y�y,n��<�0��bc����DLPP�1�`��+R�@R�F�Z��XT��A�IG��r��a��}"a������cٽ��2�ӣש���%��u4��#�e���J��T������9���.�Ctw��pJ��V���N
L$��}���F%�-�o�0�'��4��)�J#2�����ȖV�A�Z0콷
��;�y�P���5] ډ'3��u3��(wǑ˿�K�#Ij[%��\io�������A�����f�X�S@o��H�1�)�?M�6�A
�+��C
K��=��(uS��q���"��F�3$�3�Ar�t�A�'��D�>�G(�q�`V--g�Mz�����g)~3y,Ϯ�l�[�L��w�v��\]��0���F�:�_���H[�����
�|��[��_��<��D���u[�4��RŊ�xؽ��oы
�\�v@H<���O]5�o��
l�PK������`�����4�
�8�f��c�bP���6eF���jK5���}��ř��rr��h�N��LG�E���59����Ql��c���̓ۅ'w��"|����6�)�Q�1���Z�wsl�r��y�0G��!.s�<��j���}�o�C��a/���
&��e���(�H۷S�+0NC���Sk���� )o/��X�6��}��"����=҈�k�3 ����_֦���?p��\fD؉������H���C��ֱE�O���CQ�5Bʲ7��~���k2�o�dx2S-44�c{ �q��hh.�oS�g҆j�9�lR`2��S�4��$�m_ɂ5^߉n�j_�rU���c��+p�͂�?z��6
�ew�����]0ӿk��?n=���ݑ���]\�_�]�v`W^�|�`_l�e���mv.����u!��Q��(K?���G�h�qd�%0M�0������'$�^�>��gYܖ~p�WL�e����M!�mg���6Bs��	��<��T�E�u�����LlS0�
jZi467�$*�we] ���L����w��l|8P���FӠE+�8�<�xu�w�V/��5�iA�:S�;�?wEM/�tK`�jc�f#^o��,�k�^���GUB�K�=�F���s���O�Q)�hƕ��;��ܬ�8�,��m<�%^mhIl@1�ʒ��얷P����TQ|�`�~�m�T�]�
�형�9X��1��h2�J��gK^Rq�6'"����K�lw�������i���]�T��΅xDx�u��5c�0���JY�3)�zЭ��z;�[�=X���F�MpQ$14䁫%Rr��H���HbfkC���9�����k��¸36�A���cPD��������x�y��V�EǄ�`����Z�#P�@��<�k1�Q���]�SAq	\;�� =�on=w�\��?���v5^}���qa1܅�c$i��"��Bcԓ���/��h4�!�i6c�!��Cr
���Tur��GxԮ�7��R�f��/�/6�*IU����@�<�;,�T�+��I�~K��U.�t������1�M��P����_��*�Z���a *��ҫ�<�Ň��8Z��ha�u��+��&���6��6g�X�G��:�A��p#]P��-���	8n��ʚ*v��nZ�U�t+��D�`;#7�7B�a��PƑ!`��?Y�M�8��^���V2�]�4�f�6b�"+:��	ꬄ�h�q���.9�@������;Ue���ׇx�L��Xo��L����@�CX�:F3�.DG���h-��	�+Ff���~��*�K6�R�m�I�9�\�
��nm�9<	L��B�*X����{N�{e��:�dCM�a�+�?�Mq��2�ԡ�u��X�R�[	ya'�Ip1�p��񚅰��hr:;�n��'��0�i3�S�^��§��.����";y���!7^�h���A�����Em�ꗟޅ�`��F�����r��!�������o�e�O�Ԓ����a���$r�R�Zh��l��C���
����
��ȝ�ɇSġ��1���c8�������#��kݳ��A��.����W���ј<�/��c!M墂���I'��W'p�h7S;�5>V�m{��$�
a���W�*�\���೤��e��٫f��fc��a`0,��gK��ͤS�z7�a�H�L6�>;os%�\�q�vw��A��	�٬�8W��b��ߩ˺Y9\��,���S+T��I_EU�'N�(7�����ƔF��wBo�X�s��$ٌq04�&�YO�qm$뫉���7~����!8�frgU�E���B~V��	�+1@�#��uD������"^�`8HU;�:���B\sк����S�@}�WN/����sr�������5'�h�.�T�2����'��	0Nr�»��ꩧݱ֠d��kZr��״Մ�y��z�]�����x�9)�J�U��h�$rQ�Q���za"JZ|nӓ���/=���B(�B�Ԧ�>��t!�|Ji��tj"�SB����I#P�N6�`�:�|�uɈ�\�|t2�g]3���7O��a_�c��z`���t�8�<�������A����Q:�"�U�9{�@?��E?t{hSNR?�3�Eۜ�+�E�r�A`V���S�a��5E7Ka|��/�~+Q?���Ŕ�bDIġV�q����������_�B���sp����x�TO���ܪ��W����ZӝGߪ��kt�A�?hQ�M'}�v�;�΢.�׆��bW���7R:�'�`�8�xt<r�3s��D���P&���h���Y|�n�m�Y����oT�%xi����xy����G���OvI��0���$c��v�Ȳ�VƑ���9��NY�r� � 
e��t|.����T��͉{�#8O�k�?a�B���\]E�yE���t��`TvH�[='��#)�G�%�cM�i]�{N����L3ӽl���f�dxOZ1�
���)��k�Q	��XU�
�n����,3�!�/��L�!5�z�	�y��0�Օ��:ZiG�R���`�c�mK��d<�7��E"BշI�*M��R�����)�(d�a���z�{��E��?�`�)��d���n@�a4*ԍa��'Ǔ�T�gM��5�i������p��k5�7���E���p��̀�n4��Za�.x[e�bz��	c�_��f4w����j��3Nu�	Ǔt����<�l�.'����Y.cj
��\*ޘ6��L�\v`�K?�|��j����#��H2�
�qg��i�S��p�x����#>�+%��[�r��Cf����h�6:�*�ďYa����3�?�B�.���8YY)�./0�Y�b���V�9��e���0J�E��a�T��19�,.��\�!�	T�_w!W��o𲰔t�T�j���Ud�����0
�C�c��tJ�hq4_x�p�l�Byn��\�K*�l�)-�53�-���s��w��K�QZ��Fh���Ev�����u��ģH�p���R�Cv�P������q&�r1Y��	������"�=BhYBh�3bh�n�񚁂�f`������K�Y���h�"sI�ٳ�M�ir�ID^�ewFq�1����P�i�guo��A��pFD�fW<���[�{�KV���y��R�ĵ�g��l6�g�9�-#t`�t;԰�@ĸaUVtT�����^�>:/3�78���4�v@�G&x�Cu;��Jk��#�9��r�v�-.�'|A/ʜ�l���Ubr��So��h�C�K��X%�/�X��Ђ{�n����L��g�]G۶2������`��#�{�[�vY�\1�����bT�>0��҇��y�/��M�JI�[_*�T�����4
/�]0m#�)����Ї�f5p���$����ՠ:���cOܘ�����u�B�DA�(xcҵ^DI���};��7���
���a�)f����~IÖ�[�8/'Z��&ܑ���m�����=�n���b�-/<���(U��g��5/Λ����0����6c��~�7���)F@z|��CV������E���E���VZJ��E��{Qc}�[���Xs+���[_�-���.��������*���.�_�Wg+mu�T��̝�e�yD�GG��=��4BQ���v����<��`�{xp���D��$%'/i�1����*���l0�m�Ƶ�� ��k�-·���ۋ�qTN
k����	���N"�Ʊ*mǘ��j�|�mN
$��iv�N{ȗ��&'J�8���8�xzM �.���\mPmD)�\�X�<G 0-�|��5.��N����x:�?�P���+�'������ot�,���
@�m�{$�_�i���Ġ�j�Zm,>�f���0d�Am�$����0������`��l�|<���~P�8�f��,3�����>�Au�Rz�a�m[��5k�^ `��ȠWh�Q6�c�,�O����Yn:��r��B,VT��J���	�\�L��Jn��b+%�js
�Y8���(�!�� 
p>�M����G����Zs��X@�gh.}SR�D�w`5@��F��:~�(s�����0|��~��=���@�]W@��2#o]N��ct��
0C�x�9����*�h�?v�}���ulp�1|��kqx���-��D�\L�����^(H�lAsE��luND�'�N�0��5J�E��; �g��܀Ηg	�&֏�������7���P|�����x+85�ƨ�8�q]��'�f����ة2��24\p��\P����.
c���;�3��k��ZX��O���v�>�h�#"ж�ݍ�J��vGmTS�Q��W��@"A��6�Q����*�I�*��.D�D-jr<�����!�E]<-�AM���m}�8�1�V��ah�
J�:T��B���n�ꪏ��!�\ 3$ ���9�
�%E΃=�/#ؿ�ܥd|���ۗօ.�<��߈�G�0�J�-mH�|2|5Sw�V����F��b��	�`�[��se��_�ʏ��?~!��Cq!��c0��pG�~�+���%��!NAT��2�K��st_Kת��
�}mb~�q��=���g?�"���*d� o@])��~����X����C�Z�v~	e8���`��2��!>�-����rL��x:E��@5�v�$&��y����AZ�}�V�j��1������u�orV ;z	p���g�4z��q���72�I��kO��x&�ߢ0�����@��Qf��+;��|F���+�%�f�3�uǇ�m�������&9o��l�%&iޕL��"v����&�Si�\|���
X@u�:�����")u!�Wc� ��ݏ�.����#�j��.�,��;䡠(~9�J�X�PHw��{�k����;vb5NƓ
��5�+�g��1�W+z��fF�A�2��,�!��v��2D�om^����8g���<�2Jn�
d8xԖ1S��a��)C�T@���pǙ���>ږ��v|��@����������9���
Գ�x7f
wT�wV���!T��x��.h������z�ӭ[ �S7��s��}d��7�\`"�"
ê��ē���
�dq�p���,B�D��}��N)�ۚ�h����j���*�mi�Y
@�T��*e7Yu:����^�^{@���4֑?Db
O���\j˝v,]z��)B����z�������:��)�n��fh�@��3&���d�����	ulo���Ƙq(���W+H�P6��b��$�U���ze'��&g���X=���P�\Rʼ�b���8�kھ]��޿����iҟ���2_��
��.hZ�Ռ���V��L��Н.7ڠ{�?��cʉ�Zt���b�t=�����<�I]{���5��ق=�rU!���T-����bt��D�l�0��ό��x8���H��ݟ8�xg�����O�˕�P�i�$����MP��1�Z�}�U_R0JB���,�t�0������9nD=��E܈���?[�������[��D)B�$�ΐo���:��O�~��xi|x��ެ�ph�߯�{����zS�}Y5��=$��~y�
P����d�=C����Jr�s9�߿�>�T��|�顺���OvV������eĐݤ��P�P��4z��ų����n6"�H�����,?Ě���N�֖�e�m��u�Z]�p��b���L�ȅ�E7����}�]��P� �z��e�s@w������c�ó�����?�?N�cy�9d
.�m�qa��b���ᮁ��',����P�$��ʃU��ݑE�$!1X����i�ƥԵ����a92)�2.E�	}��,շ5Z"�dH8��)����C����
�؉1��.��t�0�x���@џՒ�.�
�K{��b��t��R=6�8�+M/�7)�m��H(���]L����8���8��a���C��r8&XH$��5
�h���%�ҹ��x�t}'ڸSO�c�
�&�b��򙐬Z׎t	��D|��oE�	|:��S&�`]��	�X�z�J�H]Z�A��lΎ�	���0��zt�󘍭@���<���C��3@|Ё�D�NF1h��/}����@(��Aë�Z��Kß�����z�������L������
��M��/�7��X<k|�	��F�(6�)�J3�V�hj�� h7G��;�>�K��q����l
�g*]�N}ů�Û ���
i�m�)[M�-�.�Z���6])+E��?�F�t����
���ť�Η� BAe(�����|�=�_lO^� �V-��'?�����e���=�Z9�
�Ʀ𣗞�?���r�V,zvJ���^>�d��Z������:dAҴ��P�����&��i8iCw@��ȇ��t�q��l�џ��̟��<z}��&��\ϫ��f~0*q'�ը�
Zū���S�oh��g��]������&S�s�Z!Q���c����&��J�{���
�+ԀpRG��p���?�C<��A�eOK5�q7[��;_�)�at�C�2���.�&�6ZO�-����t��X�4�_O��F�jљ�E�����t�\��
��L����xԞfG�<�.�_3Y-k�%\���x�hr�S%�o�
���6�巵�u?�5��������QR�O�P׍�E�+��by4ٖ\�cmT���a���x�]��7��S7m���׋�Q��P�XY׵�8T��b�=RivV!,���С�-T�VJ��<��}J��/���A[�f�kd�6��XLo���g��Y'b��C��X���TM��O�x�G��sJ�:16yI�!�8jT�̲��.ѤY�%���6	
a��,����wC@*����%����
.���X��a o����;"�t�^l�
�
KX�Lر��6ICȢ�!+QՆ��m������):<����-���{}���[����'=�!������V}33�O�7�*$���x�)�B�7E�S��X����4;\���5�� ;J��t�	碊#+����yA*�ݢxb�	��M��̥w"��"|cy[±^��Ě�~����>z��3���mw&ec@��$C���<��R��R�W��-T<6��Pf0��\(2�R����?��L�_vv�;���jyQ�D�������"�=��)���)�����[ܱ��I%�6��PyQAwgg�;�
��4�|ٹa�]��^f;��@'*�HV�:�" U|�����W�XU�:D�$�Qa%MD_�>B����#���l�AZ�T����9��l A&�>=��O�$p���bڙY��`Q���Gu���ft���`<?�F��h�@�
@3@`+�vF�FR1��ԕE%�ѡR2.F�Z,����XI����%�
���5�m"ލ{�F��m΢Z"k���K��I�8�-[��__u�8�v�a�H��
�'E#d&��a!���bo�����n�{ʊ�f=��H."sū9���V�f�yy�y��LV1��`�R��������o�����6:i�����M��r��2V�]u��8���J�S� G��f�o��y ��l| �&��RǺFs��?>��>�|æ�f�z��4^���S�׊z�c���|Pߤ��U�[ӝ�e���m݆���~2�����H�p�q���Q�	^z�j��-�T~�
�
����bT=W����]u��N�}u� ��6t�׊bx�j��5`/j��l���ǭ��Ɲ(�YئM�Mх������̀K��8�y}�֛{ln��A�c��f���]9�~��W��������J��DAץ	D����*ཱི@��ݎ
�M�S�.�G�P�>��#۞�
�$"����3�
h��pf>���7h�u(�܍���r!�$E�G��-�[�~8=#���0���W������ve�N��I�A�)�:��?�
fdf&@��a9B�0%^�:!qG�-uK�#��e�|\+��@������w�^(q��z�/��),%��g�*��k�Wc��.Y��4c+��H�j�|6����&�Ά/���-�z�_D�|	��4,��3�,xO�oY$���B������
.p��5���"Q�~V�Ւ;t�������v�U����:�
e�{�O�|E�|�3�nw6��q�M�yr����F��i�{�
`�x�!��g&��[�P�yKײ��:�WRC��Q�� Q��a�]Յ����>m&i�6��ѡ{�ga�tZ�l�A�bf�����^��M�
x��a���Q���A�اp�'����e>H��@B+ �>8}@u��{6FcZ�4`!��<����Uk)���щw����!�F��$�9��B�j��)IQ6���R�=��66��d\$U�4��l��nP�?�=|(�D�C���ð1H
^͡,��:��@�W�EY�`P|��w�;����6�	��2%�&Q&�:�ǫ����l�~�7�y����޳�-PD�����R������,���X�X���������܋~���Pr����A�u`��U��?d�
5ӌK�YD��fI!��r�z�8n^LK��c�=x�()E��HA �����C���0sDNQ�����5$�6�ĝ�̙SL��Z[xc������Y!�����h��\�����,�'��Bi�E|7��(�PMm=�;����݋�:K9j��e�t���uQ[[5?�Khx��AVc���(�xyĕ��xa�/Z��?���wA���x��ނCA���$8B���6(:R��L,œ�Th8Ias�V��~��{�C���s�7Į�EE�Δ{���wl���1}
'���A3/�@�U8�K`um:�g�
�9븜
�ҏ�O=#�k*K�p�
�/S����oa
��\Dh�D<��ٸd�LJ9�����F-j6�5�{�+�^b:
�2�lNut��Yqj"����ܚ�k���A�5](���i�:U����A�z=�|�<�m�tI�z�{�l��׍���r���H�2�GR�����e-	�B@���0�����n�G+I}>�R6�������!\��Y��cU�}��i�26����A��i~�ո�̥b��),5>�0�u�tY� ��:+Oi߫�f����օ��d�H�F�F��A�SJE�h���A�_�L�:8��L�Y�#�:/T�ֲ0$`���/�z ��S����x�f���Ţ�a�lb�/3[�o;�L���Z:�٩*������9��^���/�"E��e�Y5��w����Z�E¢D��S�7�G�
���\j뺯��@x�a�+������b�<@�B.Pg���yUS�o5>�J�)��kl*f��tɢ;��_e�˜�����q�T��DAP�����,�1��\��a0}0��S?�fc۳��ᇉ��O��$+���j��]�����$=� ��
?��K2��H���4��������UR�(W
8�wى�b�]Ф6Ԏ�ۋ�Ljr\[e/����b�P?���-���x������b+�T�F����bY�Ye�@oh�*��mU7ɡ��<-�������}�B��Cl%I$[�\+�ҥ�r�w_[z.��KϿ����A��2�~*�`D�
0��"L!VqK��癥qB����"u�/��;�x�4DK�L}Ʋ���%�����9��.�/�,����w)@ŋ���E�*@��Am���'k3���#��T��
�DQ(>Ɩِ�="2�Eoc;eD�F�ZEլ�r�8��Q/s�v�
WR��B�p@=��'�б�ԥ��|/�������!+v�$�nq-���`�88�0Y>�j�����`�E]r]n�$�>�A��La�?���%wb�0K��9D�i?�����3�z�b:y�F������9JD�R�&��� ����OM4��*�(�OσA	Ю��/ˠGߖ�O�p�|����*-B�����l�=��)�-�y(|��CnX�����b6d,��0�����N��wՋ����l�c�)}��Um\h99���f"^Ґf�X����aYV����;����Q�%Q�;�Z�f����*+6���X�n&lD��~]���7����rp��5�F�d
��/ɋ��ެ9r�p��eHR�q	 &�8}�hB�Ҧ����I	�v2V�ZG�i�8��`���x���~
e�;Uv�}�**K($�|P��e���b����Y���;,HDrƶ#�<���IlG��h<;Q����v~$�
���6���Ź #m((�B��g �31z���:�x��;��tuc��՗c����H�$bC��tင���2tN���K�?5�i
)F���p�q�ZW����rt�\Ƙi��^�vYJ��HA�\����r!�W��^G����1���'#q�K�(�Mc��mu�P�:��<�������)v��^��~E[(��!̱�(�=B��f� ��nLY���E���V�@K}��X����*��^s�OU��~ZWm�ʭz�|"�C�0C�v~<>�!-�e5t���:T�:����'*�s^*12���Q�Ϯ��f�w��xւ?��
1�lࠥ����"|Li�H�as$AŴ
������k��ņ��T������dV�RV��,V5�Ő9�k2:F|Rvt�~�t�~����G�����a:0	�[���rD	7�M�1�i!?�������d<%$��}� ���g�^���f���c3�o�(�]��YE k)�\�Bn�u���wĚ)c$��l�jn
�v���;��S��.��ЋW�N*�M
��E��96�7ll����f�#p�3Hۉ�Jq�Qk�\�h\Qk��(]٣Ρroܭ?�}y���M��h�St6��qS�LY$P�Nܒ|"��:`N(�A
u�jȤ�RM��������z�.X�[-�gݶ$�%�ա�8=LK�TtA�b�g��Χ�?<}��C��M��������!���O�c����?������p z����dgd"���U����Wy���Q���g/S���'�Q%	7KϿk뎯p����W��x�x����J��\����S�,�����0��En�z�ݟ/�"T���yg��bT��J/@�{�}U�h迲5�&"fx����
3{`
��D������jL��jD�d:���E����Q�*��'�jHhp�$�|z������%�KR�z�0X"ռq�X\��41�)C�F0�xR���Isd�laj����,�a$2��'�nҦ*벁�&�T���=5t[��˗�K7l1%�#"���~Wl檵jT�b�a�*P\��p{����) ��b��I�MX�K��
�$K��N�U��{+p���y�������K�j�|�p����	��;C��i�eB�}�eX[�C,��&�S%ϸ���S#Ù�r
���f�2#Kd�@�P/]�Q��C�?b�ʌ�*����
X�B��v�G�ȸ�2�n��K���G�e�/U/��&mA
Ђ؊����x����ol����I�Ƀ!����0X�	�S�#W��H�*�avKf�2U]���G����6��=*�O M,�`KW���H�~p��n{��5q�۪�:�_����?{�r�B4Y��F���ڪ�c���f�62wp�Pm��QDUڭN<\�\���vDP)�%�1S��̣!ܔB�"G�B�.�/o�i��m�;.����2շ�_������D h}v����JiyC(�7��)_��_�UU�mi�^韕j�����l�N(�Q!Z�N�^�^+�u����ߧqg��>��z�'���O���
BH���x:�� p�.*G����l�{�0a�Sih�����6�3��F᪽^^���,Ζ��\:��{WK���JT��p��\�a��
1�jԀ2��1��9�	�2�C�^����\`,�����8l��8ə=sٮ�6O�,��k���Uټ>�y���ۓ�<o����=�L'���y6�`�oՏ��!{�#8��e˩����(7,�,N�]�n�h�D�����a�J/o�l�*/��b��_�N J���q�C?�pm�#4��������7��v�Q���C�
H_�:@��� z��?��j�<V���ӊa�X5a�����p��t���o�z�b�a�C͘Lǳqw<������?{�����L~�>��Џ��G�u�W6q4}}����c[����k&��=�<���G'�k��,$��r��{��ˀ���:��&��5{�62M���BO ����7�ע�d��^�w0�	ܡO�F!1���@����z���u�&
�[�(����p}ǈ���p�R��	h�+���W`�X��"Gc�x���Z��zP�w��
����_7�/��*�� O��]0�����p�M>�jK�E�.�.U5ԧu�f����8�
���`��`���X��5x^]ަC�im"wK
:�G�T�
�!�I; ������l���lrSZT'ǵ�{��r'
7���&xM1~�K!VAK��,��k�7(��U��u-���z��W��{�Q���C��[С�+���w��`].��,9b^��֏�ʵZ��ˣ���>|�6O����Cc�\ݰM"ŵ��7e`Y�G�����_����ӹ����$����U����Rɹ�k괸�Хqq����GQ� �}eI��ҁ�b��K4[�4�Y�I���l�(���(H�٤i�_"T��2�z7D=:4��=U���K%EP�MA�m�vtK��%�&��6����Q���C�4�x���'"�}79��Gk�␳���3J�?1�I͏q7��QpA��ud�.�C��|���:*ˣQ���$���y.#�Ss7��ᙍ�h8�|?��(��J���V٘���b� js4�w��xM��=W�>L>Fyw�|�1b����ħ劣u=L��!bd�y�<=�@D���U%D�	��t��D�ѣO�{�m͇iw�
�	.0?N���v՝E4�у=Q���\�%�%SV[<U/֘^��e{�ˋN?����v׊�{Yd���S\=Enko�W�RR��Z�_�/�|H�֥�&6U�`l+�(���m?�H⪲,!?f�k1�{k"�5Hv��7�]����l�'���q�,\9�I�v�i��2��wT�zpB��h�8mk
(���5�
��59ƈr����C��ҍ�8�ոC���s��
���h�+
�-	���%�\�
U.�|�@��;ՊV���pP�'�W@Z-�Q!9.|k�H
�s�o��*��l��1NE�
-S����������(q3i�7����\�H�'Q�j\�4�O6@ںqw�W�8^k46��d3irN}D��á:�֒����Z�
�E_3�m�u��������ܾ�1P�1˭�-�ۚ�N,O��h2����z���%M��Ґ�+fq��m���������^3K�����8��d=�b��)��xCQ��=��ě�J�x�+��\��
�[�6�v9ó��\9�,��sY,��ohR�w���A.�$o=�%�tT�T��FK�V�C���/�=zV���O�Z�f0�e���j-W���quƇh�E�f�{�.҃���B�q;�ug����A�Nx*��h#�nw"@��誅a!=������0i��<i�"{ԢlD�ut5�"0�wHv]ЦQ�`�N����®�q���d2����4[
$���ٴ�p��P�IM�fe�T�2�笭�{��;c�VX#S�j�9^�R�2&ݪ����o��׽�~
��&8�]�ꍥU�ٺ��
�ʁG����f��c��4Z�]��kk�Z)5t4���X��4~[��5x�?f�`{\0�����x��ڣ1����f�G%t��g%��&�����z��"��m��f�	��d�8�����L��t��&� :�FpeǦ�S͜E+P��P�G��)��3��c3q<�ˆ�І�Ft�cP���k|���x"�`9� gH]Σs������TY�G%�ME���T��Fw��=��Ў
��GUw8��,�������[�^鶗���H��^����§�tjʭy:����U}���~�E���Ղ��
]�_���l�tl�%)��WF�I9�q3�2u=�Wx��V�ԅ���\׹M,ZW��(̭J�xjEN�D�o��#��%y����0b~���LtB�b����!�(NS^z��O�Qg���7� �"1M�3�T)"�*�)� _�_Tp1�����Z��~q��#�\��QuI�{��]��B�6��poQ��ʽU��O�K����%�R�{p����wղ��iĺ�����뇘_�R���P�N7z���f�{���W�d�"
Ƨ��� O(T�`r�F\+A�"�i�T=@� ��('��(��I��"|�PK�� <�hm�:�?�#�{��u�Ta��Hq�d1J^QƇZ.�֨�g��TY�-�K{��x�?��QotX�����V�x����"'&1:/�40�6Wp�
!�������� rZn���
�Y���ڰA���[0Ơ������ny8&rh!�*(��{�H�����;R���_=i�@�Ӟ���m��IC~%m^U/l\,O� U�©�4=c[�Jد�ف�l� ��>�|�?�}�]Ѥ{���L�Z�	Ꝑ�!�
q!�6��Aعs��<X��kQ[�OW�����w0>�nu��~���W}�k�j�V��͍�k���h�5no�)j�0�C)������]����O��׍���wC��m�)J�����g�7:P�"����~�������m�9*C�:���
�Ю�o*%����(���~U���k����V�]��9���;��������c��?������篻�_�={���q��o6o��y��\߼��T���ll��_��?��~���ۼv>�	il^{���=���&k�}��6�{��>���͵N�w;��e�֝��ag�f�j�^}�>W������s���\}�>W������s���\}�>W������s���\}�>W������s����#>�Z�%���
