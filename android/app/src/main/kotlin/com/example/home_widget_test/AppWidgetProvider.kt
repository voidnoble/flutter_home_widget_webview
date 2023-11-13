package com.example.home_widget_test

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val _counter = widgetData.getInt("_counter", 0)
                var _counterText = "Your _counter value is: $_counter"

                if (_counter == 0) {
                    _counterText = "You have not pressed the _counter button"
                }

                setTextViewText(R.id.tv_counter, _counterText)

                // Pending intent to update counter on button click
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://updatecounter"))
                setOnClickPendingIntent(R.id.bt_update, backgroundIntent)

                // 위젯의 메뉴1 클릭 이벤트 리스너 설정
                val intentMenu1 = HomeWidgetLaunchIntent.getActivity(
                  context,
                  MainActivity::class.java,
                        Uri.parse("myAppWidget://click.menu/1"))
                setOnClickPendingIntent(R.id.bt_menu1, intentMenu1)
                
                // 위젯의 메뉴2 클릭 이벤트 리스너 설정
                val intentMenu2 = HomeWidgetLaunchIntent.getActivity(
                  context,     
                  MainActivity::class.java,
                        Uri.parse("myAppWidget://click.menu/2"))
                setOnClickPendingIntent(R.id.bt_menu2, intentMenu2)

                // 위젯의 메뉴3 클릭 이벤트 리스너 설정
                val intentMenu3 = HomeWidgetLaunchIntent.getActivity(
                  context,     
                  MainActivity::class.java,
                        Uri.parse("myAppWidget://click.menu/3"))
                setOnClickPendingIntent(R.id.bt_menu3, intentMenu3)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}