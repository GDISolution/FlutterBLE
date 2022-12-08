package com.ble.flutter_ble;

import android.Manifest;
import android.annotation.TargetApi;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.*;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.bluetooth.*;
import android.util.*;
import android.content.pm.*;
import android.widget.Toast;

import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.lang.reflect.Method;

public class MainActivity extends FlutterActivity {

    BluetoothAdapter mBleAdapter = BluetoothAdapter.getDefaultAdapter();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), "com.ble.flutter_ble");
        channel.setMethodCallHandler(handler);
    }

    private MethodChannel.MethodCallHandler handler = (methodCall, result) -> {
        if (methodCall.method.equals("getBondedDevices")) {
            List<Map<String, Object>> devices = new ArrayList<>();

            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            for (BluetoothDevice device : mBleAdapter.getBondedDevices()) {
                Map<String, Object> results = new HashMap<>();
                if (device.getName() != null) {
                    results.put("name", device.getName());
                } else {
                    results.put("name", "No Name");
                }
                results.put("address", device.getAddress());
                devices.add(results);
                Log.d("bonded Call", results.get("address").toString());
            }
            result.success(devices);
        } else if(methodCall.method.equals("pair")) {
//            Log.d("Pairing Call",methodCall.arguments.toString());
            BluetoothDevice device = mBleAdapter.getRemoteDevice(methodCall.arguments.toString());

            try{
                Method method = device.getClass().getMethod("createBond", (Class<?>[]) null);
                method.invoke(device, (Object[]) null);
                Log.d("Pairing Call", "[pairingDevice] " + device.getAddress());
                result.success(null);
            } catch(Exception e){
                e.printStackTrace();
            }

        }else {
            result.notImplemented();
            Log.d("MethodChannel", "result.notImplemented()");
        }
    };


}

