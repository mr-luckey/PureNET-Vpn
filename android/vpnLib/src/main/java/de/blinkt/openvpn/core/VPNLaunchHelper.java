/*
 * Copyright (c) 2012-2016 Arne Schwabe
 * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 */

package de.blinkt.openvpn.core;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Vector;

import de.blinkt.openvpn.R;
import de.blinkt.openvpn.VpnProfile;

public class VPNLaunchHelper {
    private static final String MININONPIEVPN = "nopie_openvpn";
    private static final String MINIPIEVPN = "pie_openvpn";
    private static final String OVPNCONFIGFILE = "android.conf";
    private static final String[] APP_SUPPORTED_ABIS = new String[]{"arm64-v8a"};


    private static String writeMiniVPN(Context context) {
        String nativeAPI = NativeUtils.getNativeAPI();
        /* Q does not allow executing binaries written in temp directory anymore */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
            return new File(context.getApplicationInfo().nativeLibraryDir, "libovpnexec.so").getPath();
        String[] abis = getDeviceAbis();
        String resolvedAbi = resolveExecutableAbi(nativeAPI, abis);
        abis = new String[]{resolvedAbi};

        for (String abi : abis) {

            File vpnExecutable = new File(context.getCacheDir(), "c_" + getMiniVPNExecutableName() + "." + abi);
            if ((vpnExecutable.exists() && vpnExecutable.canExecute()) || writeMiniVPNBinary(context, abi, vpnExecutable)) {
                return vpnExecutable.getPath();
            }
        }

        throw new RuntimeException("Cannot find any execulte for this device's ABIs " + abis.toString());
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String[] getSupportedABIsLollipop() {
        return Build.SUPPORTED_ABIS;
    }

    private static String[] getDeviceAbis() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return getSupportedABIsLollipop();
        }
        //noinspection deprecation
        return new String[]{Build.CPU_ABI, Build.CPU_ABI2};
    }

    private static boolean isAppSupportedAbi(String abi) {
        if (abi == null) {
            return false;
        }
        for (String supported : APP_SUPPORTED_ABIS) {
            if (supported.equals(abi)) {
                return true;
            }
        }
        return false;
    }

    private static String findFirstSupportedAbi(String[] abis) {
        for (String abi : abis) {
            if (isAppSupportedAbi(abi)) {
                return abi;
            }
        }
        return null;
    }

    private static String resolveExecutableAbi(String nativeAPI, String[] deviceAbis) {
        if (nativeAPI != null && isAppSupportedAbi(nativeAPI)) {
            return nativeAPI;
        }
        String fallback = findFirstSupportedAbi(deviceAbis);
        if (fallback != null) {
            VpnStatus.logWarning(R.string.abi_mismatch, Arrays.toString(deviceAbis), fallback);
            return fallback;
        }
        throw new IllegalStateException("Device ABIs " + Arrays.toString(deviceAbis) + " are not supported by this build");
    }

    private static String getMiniVPNExecutableName() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
            return MINIPIEVPN;
        else
            return MININONPIEVPN;
    }


    public static String[] replacePieWithNoPie(String[] mArgv) {
        mArgv[0] = mArgv[0].replace(MINIPIEVPN, MININONPIEVPN);
        return mArgv;
    }


    static String[] buildOpenvpnArgv(Context c) {
        Vector<String> args = new Vector<>();

        String binaryName = writeMiniVPN(c);
        // Add fixed paramenters
        //args.add("/data/data/de.blinkt.openvpn/lib/openvpn");
        if (binaryName == null) {
            VpnStatus.logError("Error writing minivpn binary");
            return null;
        }

        args.add(binaryName);

        args.add("--config");
        args.add(getConfigFilePath(c));

        return args.toArray(new String[args.size()]);
    }

    private static boolean writeMiniVPNBinary(Context context, String abi, File mvpnout) {
        try {
            InputStream mvpn;

            try {
                mvpn = context.getAssets().open(getMiniVPNExecutableName() + "." + abi);
            } catch (IOException errabi) {
                VpnStatus.logInfo("Failed getting assets for archicture " + abi);
                return false;
            }


            FileOutputStream fout = new FileOutputStream(mvpnout);

            byte buf[] = new byte[4096];

            int lenread = mvpn.read(buf);
            while (lenread > 0) {
                fout.write(buf, 0, lenread);
                lenread = mvpn.read(buf);
            }
            fout.close();

            if (!mvpnout.setExecutable(true)) {
                VpnStatus.logError("Failed to make OpenVPN executable");
                return false;
            }


            return true;
        } catch (IOException e) {
            VpnStatus.logException(e);
            return false;
        }

    }


    public static void startOpenVpn(VpnProfile startprofile, Context context) {
        Intent startVPN = startprofile.prepareStartService(context);
        if (startVPN != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                //noinspection NewApi
                context.startForegroundService(startVPN);
            else
                context.startService(startVPN);

        }
    }


    public static String getConfigFilePath(Context context) {
        return context.getCacheDir().getAbsolutePath() + "/" + OVPNCONFIGFILE;
    }

}
