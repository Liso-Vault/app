import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../supabase/app_supabase_db.service.dart';

final now = DateTime.now();

class StatisticsScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static StatisticsScreenController get to => Get.find();

  // VARIABLES
  final db = Get.find<AppDatabaseService>();
  final dateFormatter = DateFormat.yMMMMd().add_jm();

  final dateRange = DateTimeRange(
    start: DateTime(now.year, now.month, now.day, 0, 0, 0),
    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
  ).obs;

  // PROPERTIES
  final profilesTitle = ''.obs;
  final profilesSubTitle = ''.obs;

  final devicesTitle = ''.obs;
  final devicesSubTitle = ''.obs;

  final sessionsTitle = ''.obs;
  final sessionsSubTitle = ''.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    load();
    // loadToday();
    super.onInit();
  }

  // FUNCTIONS
  void load() async {
    clear();

    loadProfiles();
    loadDevices();
    loadSessions();
  }

  void loadAll() async {
    dateRange.value = DateTimeRange(
      start: DateTime(2021),
      end: DateTime.now(),
    );

    load();
  }

  void previous() async {
    dateRange.value = DateTimeRange(
      start: dateRange.value.start.subtract(1.days),
      end: dateRange.value.end.subtract(1.days),
    );

    load();
  }

  void next() async {
    dateRange.value = DateTimeRange(
      start: dateRange.value.start.add(1.days),
      end: dateRange.value.end.add(1.days),
    );

    load();
  }

  void clear() {
    profilesTitle.value = '';
    profilesSubTitle.value = '';

    devicesTitle.value = '';
    devicesSubTitle.value = '';

    sessionsTitle.value = '';
    sessionsSubTitle.value = '';
  }

  void loadProfiles() async {
    console.info('profiles...');

    try {
      final query = db.client
          .from('profiles')
          .select(
            'created_at,license_cache',
            const FetchOptions(count: CountOption.exact),
          )
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc());

      final response = await query;
      final responseFreeCount =
          await query.contains('license_cache', {'entitlementId': 'free'});

      profilesTitle.value =
          '${response.count} | ${response.count - responseFreeCount.count} (Premium)';
    } catch (e) {
      profilesTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    try {
      final response = await db.client
          .from('profiles')
          .select()
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc())
          .order('created_at', ascending: false)
          .limit(1);

      final createdDate = DateTime.parse(response.first['created_at']);
      final formattedDate = dateFormatter.format(createdDate.toLocal());

      profilesSubTitle.value =
          'Last: $formattedDate -> ${response.first['email']}';
    } catch (e) {
      profilesSubTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    console.info('profiles success!');
  }

  void loadDevices() async {
    console.info('devices...');

    try {
      final response = await db.client
          .from('devices')
          .select(
            'created_at',
            const FetchOptions(count: CountOption.exact, head: true),
          )
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc());

      devicesTitle.value = response.count.toString();
    } catch (e) {
      devicesTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    try {
      final response = await db.client
          .from('devices')
          .select()
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc())
          .order('created_at', ascending: false)
          .limit(1);

      final createdDate = DateTime.parse(response.first['created_at']);
      final formattedDate = dateFormatter.format(createdDate.toLocal());
      devicesSubTitle.value =
          'Last: $formattedDate -> Id:${response.first['id']} -> ${response.first['data']['platform']}';
    } catch (e) {
      devicesSubTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    console.info('devices success!');
  }

  void loadSessions() async {
    console.info('sessions...');

    try {
      final response = await db.client
          .from('sessions')
          .select(
            'created_at',
            const FetchOptions(count: CountOption.exact, head: true),
          )
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc());

      sessionsTitle.value = response.count.toString();
    } catch (e) {
      sessionsTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    try {
      final response = await db.client
          .from('sessions')
          .select()
          .lte('created_at', dateRange.value.end.toUtc())
          .gte('created_at', dateRange.value.start.toUtc())
          .order('created_at', ascending: false)
          .limit(1);

      final createdDate = DateTime.parse(response.first['created_at']);
      final formattedDate = dateFormatter.format(createdDate.toLocal());
      sessionsSubTitle.value =
          'Last: $formattedDate -> Id:${response.first['id']} -> UserId:${response.first['user_id']}';
    } catch (e) {
      sessionsSubTitle.value = e.toString();
      console.error('response error: $e');
      return;
    }

    console.info('sessions success!');
  }

  void selectDates() async {
    final date = await showDatePicker(
      initialDate: dateRange.value.start,
      lastDate: DateTime.now(),
      context: Get.context!,
      firstDate: DateTime.now().subtract(365.days),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
                maxHeight: 500,
              ),
              child: child,
            )
          ],
        );
      },
    );

    if (date == null) {
      return console.error('cancelled date picker');
    }

    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    dateRange.value = DateTimeRange(start: start, end: end);
    console.info('start: $start! end: $end');

    load();
  }
}
