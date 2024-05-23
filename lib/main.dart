import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Health Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _result;
  int healthyChickens = 0;
  int disease1 = 0;
  int disease2 = 0;
  int disease3 = 0;
  int total = 1;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _detectChicken(_selectedImage!.path);
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _detectChicken(_selectedImage!.path);
    }
  }

  Future<void> _detectChicken(String imagePath) async {
    final String apiUrl = "https://detect.roboflow.com";
    final String apiKey = "REKRi3n8N6cMWAJxLl4e";
    final String modelId = "healthy-and-sick-chicken-detection-kavqw/18";

    final Uri url = Uri.parse('$apiUrl/$modelId?api_key=$apiKey');

    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();

      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageFile.path.split('/').last,
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> result = json.decode(responseString);
        setState(() {
          _result = result.toString();
        });
      } else {
        setState(() {
          _result =
              'Failed to detect chicken. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _showDiseaseInfo(String type, String disease) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(type),
          content: Text('$disease'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updateData() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController totalController = TextEditingController();
        TextEditingController disease1Controller = TextEditingController();
        TextEditingController disease2Controller = TextEditingController();
        TextEditingController disease3Controller = TextEditingController();

        return AlertDialog(
          title: Text('Update Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: totalController,
                decoration: InputDecoration(labelText: 'Total Chickens'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: disease1Controller,
                decoration: InputDecoration(labelText: 'Coccidiosis Chickens'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: disease2Controller,
                decoration: InputDecoration(labelText: 'Newcastle Chickens'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: disease3Controller,
                decoration: InputDecoration(labelText: 'Salmonella Chickens'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  total = int.parse(totalController.text);
                  disease1 = int.parse(disease1Controller.text);
                  disease2 = int.parse(disease2Controller.text);
                  disease3 = int.parse(disease3Controller.text);
                  healthyChickens = total - (disease1 + disease2 + disease3);
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 234, 157),
      appBar: AppBar(
        title: Text('Health Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chicken Health Detection',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              // height: 120,
              width: MediaQuery.of(context).size.width * 1,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 208, 234, 244),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/icons/disease1.png'),
                        iconSize: 25,
                        onPressed: () => _showDiseaseInfo('Coccidiosis',
                            'Description : Coccidiosis is a common and highly contagious parasitic disease in poultry caused by various species of the protozoan parasite Eimeria. It affects the intestinal tract of chickens and can lead to severe illness or death, particularly in young birds.\n\n\nSymptoms: Symptoms include diarrhea, blood in the feces, decreased appetite, decreased activity, weight loss, and dehydration. In severe cases, birds may appear weak, hunched, and may die suddenly.\n\n\nPrevention and Control: Prevention involves maintaining clean and dry housing conditions, proper sanitation, regular removal of droppings, and avoiding overcrowding. Additionally, coccidiosis vaccines and anticoccidial medications can be used as preventive measures.'),
                      ),
                      Text('Coccidiosis'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/icons/disease2.png'),
                        iconSize: 25,
                        onPressed: () => _showDiseaseInfo('Newcastle',
                            'Description: Newcastle disease is a highly contagious viral infection affecting birds, including chickens, caused by the avian paramyxovirus type 1 (APMV-1). It can affect respiratory, nervous, and digestive systems in birds. \n\n\n Symptoms: Symptoms vary widely but may include respiratory signs such as coughing, sneezing, nasal discharge, and gasping for air. Nervous signs like twisting of the neck, paralysis, and circling may also occur. Additionally, diarrhea, decreased egg production, and sudden death without any apparent signs are common.\n\n\nPrevention and Control: Prevention involves vaccination with live or inactivated vaccines, biosecurity measures, proper sanitation, and control of wild bird contact. Quarantine and culling of infected birds are necessary to prevent the spread of the disease.'),
                      ),
                      Text('Newcastle'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/icons/disease3.png'),
                        iconSize: 25,
                        onPressed: () => _showDiseaseInfo('Salmonella',
                            'Description: Salmonella infection in poultry, caused by various strains of Salmonella bacteria, can lead to both clinical disease and asymptomatic carriage. It poses a risk to both bird health and public health, as certain strains can cause foodborne illness in humans.\n\n\nSymptoms: In poultry, symptoms may include diarrhea, decreased egg production, lethargy, weakness, and dehydration. In humans, symptoms of salmonellosis include nausea, vomiting, abdominal cramps, diarrhea, fever, and headache.\n\n\nPrevention and Control: Prevention involves maintaining strict biosecurity measures, proper sanitation, hygiene practices, and ensuring that feed and water sources are uncontaminated. Vaccination of poultry may also be considered, and thorough cooking of poultry products is essential to prevent human infection.'),
                      ),
                      Text('Salmonella'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 208, 234, 244),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    height: 90,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: _buildBarGraph(),
                  ),
                  ElevatedButton(
                    onPressed: _updateData,
                    child: Text('Update Data'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Check Health',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 208, 234, 244),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: _selectedImage == null
                  ? Text('No image selected.')
                  : Image.file(_selectedImage!, height: 200, width: 200),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: Text('Take Photo'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Text(
                'Prediction : ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _result == null
                ? Container()
                : Container(
                    padding: const EdgeInsets.all(1.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 208, 234, 244),
                    ),
                    child: Text('Result: $_result'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarGraph() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircularProgress('Healthy', (healthyChickens / total)),
        _buildCircularProgress('Coccidiosis', (disease1 / total)),
        _buildCircularProgress('Newcastle', (disease2 / total)),
        _buildCircularProgress('Salmonella', (disease3 / total)),
      ],
    );
  }

  Widget _buildCircularProgress(String label, double value) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 10),
        CircularProgressIndicator(
          value: value,
          backgroundColor: Colors.grey,
          color: value > 0.5
              ? Colors.green
              : value > 0.3
                  ? Colors.orange
                  : Colors.red,
        ),
        SizedBox(height: 10),
        Text('${(value * 100).toInt()}%'),
      ],
    );
  }
}
