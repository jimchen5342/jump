package com.flutter.jump.jump;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;

import android.app.NotificationManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements SensorEventListener{
	SensorManager manager;
	Sensor sensor;
	static float[] values = new float[3];
	static float[] init = new float[] { 0.0f, 0.0f, 0.0f };
	static float x, y, z;
	long lastUpdateTime = 0;
	String TAG = "FlutterActivity", path = "";
	BasicMessageChannel.Reply<Object> _reply;
	EventChannel.EventSink _eventSink;
	StringBuilder sbLog = new StringBuilder();
	//  StringBuilder sbLog.delete(0, sbLog.lngth())
	// StringBuilder sbLog.append(String str); length()


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		manager = (SensorManager) getSystemService(SENSOR_SERVICE);
		sensor = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

		if(path.length() == 0)
			path = Environment.getExternalStorageDirectory().toString() + File.separator + "jump";
	}
	@Override
	public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
		GeneratedPluginRegistrant.registerWith(flutterEngine);

		new MethodChannel(
						flutterEngine.getDartExecutor(),
						"jump/MethodChannel")
						.setMethodCallHandler(mMethodHandle);

		new BasicMessageChannel<Object>(
						flutterEngine.getDartExecutor(),
						"jump/MessageChannel",
						StandardMessageCodec.INSTANCE)
						.setMessageHandler(mMessageHandler);

		new EventChannel(flutterEngine.getDartExecutor(),
						"jump/EventChannel")
						.setStreamHandler(mEnventHandle);

	}
	MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
		@Override
		public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
			if(call.method.equals("initial")) {
				createFolder(path);
			} else if(call.method.equals("sensor")) {
				String action = call.argument("action");
				if(action.equals("start")) {
					register();
				} else {
					unRegister();
				}
				//				Log.i(TAG, action);
			}
		}

	};
	BasicMessageChannel.MessageHandler<Object> mMessageHandler = new BasicMessageChannel.MessageHandler<Object>() {
		@Override
		public void onMessage(Object o, BasicMessageChannel.Reply<Object> reply) {
			// Log.i(TAG, "messageChannel.onMessage: " + o);
			// reply.reply("messageChannel: 返回给flutter的数据");
			try {
				JSONObject jsonObject = new JSONObject(o.toString());
				String mode = jsonObject.getString("state");
					//				if(mode.equals("close") || mode.equals("stop")) {
					//					mNM.cancel(1);
					//				} else {
					//					title = jsonObject.getString("title");
					//					report = jsonObject.getString("report");
					//					if(jsonObject.has("total")){
					//						total = jsonObject.getInt("total");
					//						index = jsonObject.getInt("index");
					//					} else
					//						total = 0;
					//					showNotification();
					//				}
			} catch (JSONException err){
				Log.d("Error", err.toString());
			}
			_reply = reply;
		}
	};

	EventChannel.StreamHandler mEnventHandle = new EventChannel.StreamHandler() {
		@Override
		public void onListen(Object o, EventChannel.EventSink eventSink) {
			_eventSink = eventSink;
		}

		@Override
		public void onCancel(Object o) {
		}
	};

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	private void createFolder(String path) {
		File tDataPath = new File(path);
		if (tDataPath.exists() == false) {
			tDataPath.mkdir();
		}
	}

	void write(String folder, String filename, String data) {
		createFolder(path + File.separator + folder);
		String _path = path + File.separator + folder + File.separator + filename + ".txt";
		data += "\n";
		try {
			FileOutputStream out = new FileOutputStream(_path, false);
			out.write(data.getBytes());
			out.flush();
			out.close();
		} catch(FileNotFoundException e) {
			Log.i(TAG, e.getMessage());
		} catch(IOException e) {
			Log.i(TAG, e.getMessage());
		}
	}

	public void onAccuracyChanged(Sensor arg0, int arg1) {
	}

	float y1 = -9999, y2 = -9999; String state = ""; Long time1;
	public void onSensorChanged(SensorEvent event) {
		if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
			if (init[0] == 0 && init[1] == 0 && init[2] == 0) {
				init[0] = event.values[0];
				init[1] = event.values[1];
				init[2] = event.values[2];
			}
			values = event.values;
			x = init[0] - values[0];
			y = init[1] - values[1];
			z = init[2] - values[2];
		}
		long currentUpdateTime = System.currentTimeMillis(); // 取得目前系統時間
		long timeInterval = currentUpdateTime - lastUpdateTime; // 時間秒數=目前系統時間-值變化的時間
		if (timeInterval < 100) // 判斷目前時間是否小於 n 毫秒
			lastUpdateTime = currentUpdateTime; // 值變化時間=當前時間
		else {
			String orient = "";
			if (x < -5) {
				orient = "左";
				return;
			} else if (x > 5) {
				orient = "右";
				return;
			} else  if (x > -5 && x < 5) {
				if (y > 1) {
					orient = "上";
				} else if (y < -1) {
					orient = "下";
				}
			}
			if(orient.indexOf("上") > -1 || orient.indexOf("下") > -1) {
				if(!state.equals(orient)) {
					if(state.length() > 0) {
						Log.i(TAG, state + "=> Y: " + Float.toString(y1) + ", " + Float.toString(y2)
										+ "; time" + Long.toString(System.currentTimeMillis() + time1));
					}
					y1 = y;
					state = orient;
					time1 = System.currentTimeMillis();
				}
				y2 = y;
				//				Log.i(TAG, "onSensorChanged => x: " + Float.toString(x)
				//								+ ", y: " + Float.toString(y)
				//								+ ", z: " + Float.toString(z)
				//				);
				// Log.i(TAG, orient + " .......................................");
				_eventSink.success(orient);
			}
		}
	}

	private final void register() {
		sbLog.delete(0, sbLog.length() - 1);
		manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL);
	}

	private final void unRegister() {
		SimpleDateFormat sdFormat = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss");
		Date current = new Date();
		if(sbLog.length() > 0) {
			write("Log", sdFormat.format(current), sbLog.toString());
		}
		manager.unregisterListener(this);
		x = 0;
		y = 0;
		z = 0;
	}
}
