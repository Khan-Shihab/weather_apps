import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_apps/additonal_information.dart';
import 'package:weather_apps/hourly_forecast.dart';
import 'package:weather_apps/secret.dart'; // Your API key file

class WeatherScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const WeatherScreen({super.key, required this.onThemeToggle});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0.0;
  double humidity = 0.0;
  double pressure = 0.0;
  double feelsLike = 0.0;
  double windSpeed = 0.0;
  String weatherDescription = '';
  String weatherIconUrl = '';
  bool isLoading = false;

  TextEditingController cityController = TextEditingController();
  String cityName = 'Dhaka';

  List<Map<String, dynamic>> hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    setState(() {
      isLoading = true;
      hourlyForecast.clear();
    });

    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'City not found';
      }

      final current = data['list'][0];
      setState(() {
        temp = (current['main']['temp'] - 273.15);
        humidity = current['main']['humidity'].toDouble();
        pressure = current['main']['pressure'].toDouble();
        feelsLike = (current['main']['feels_like'] - 273.15);
        windSpeed = current['wind']['speed'].toDouble();
        weatherDescription = current['weather'][0]['main'];
        weatherIconUrl =
            'https://openweathermap.org/img/wn/${current['weather'][0]['icon']}@2x.png';
      });

      // Build hourly forecast list (next 10 hours)
      for (int i = 0; i < 10; i++) {
        final item = data['list'][i];
        final dateTime = DateTime.parse(item['dt_txt']);
        final time = "${dateTime.hour.toString().padLeft(2, '0')}:00";

        final temperature = (item['main']['temp'] - 273.15).toStringAsFixed(1);

        final iconCode = item['weather'][0]['icon'];
        final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

        hourlyForecast.add({
          'time': time,
          'temp': '$temperature°C',
          'iconUrl': iconUrl,
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getCurrentWeather,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔍 Search Box
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: 'Enter City Name',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              cityName = cityController.text.trim();
                            });
                            if (cityName.isNotEmpty) {
                              getCurrentWeather();
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌡️ Current Weather Card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${temp.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Image.network(
                                    weatherIconUrl,
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    weatherDescription,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🕒 Hourly Forecast
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: hourlyForecast.map((forecast) {
                          return HourlyForecastItem(
                            time: forecast['time'],
                            iconUrl: forecast['iconUrl'],
                            temperature: forecast['temp'],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📊 Additional Information
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInformation(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '$humidity%',
                          ),
                          AdditionalInformation(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '${windSpeed.toStringAsFixed(1)} m/s',
                          ),
                          AdditionalInformation(
                            icon: Icons.thermostat,
                            label: 'Feels Like',
                            value: '${feelsLike.toStringAsFixed(1)}°C',
                          ),
                          AdditionalInformation(
                            icon: Icons.speed,
                            label: 'Pressure',
                            value: '${pressure.toStringAsFixed(0)} hPa',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
