import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {

  final _formKey = GlobalKey<FormState>();

  final tempController = TextEditingController();
  final humidityController = TextEditingController();
  final rainfallController = TextEditingController();
  final phController = TextEditingController();

  bool isLoading = false;

  List recommendations = [];
  String nutrientStatus = "";
  String explanation = "";

  String selectedCategory = "cereals";
  String selectedCrop = "rice";
  String selectedSoil = "clay loam";

  String nLevel = "medium";
  String pLevel = "medium";
  String kLevel = "medium";

  final List<String> categories = [
    "cereals",
    "pulses",
    "fruits",
    "vegetables",
    "oilseeds",
    "cash"
  ];

  final Map<String, List<String>> cropMap = {
    "cereals": ["rice","wheat","maize","barley","sorghum"],
    "pulses": ["chickpea","lentil","peas","pigeonpea"],
    "vegetables": ["tomato","potato","onion","cabbage","cauliflower","carrot","brinjal","spinach"],
    "fruits": ["mango","banana","apple","grapes","orange","papaya","pomegranate"],
    "oilseeds": ["mustard","groundnut","sunflower","sesame"],
    "cash": ["cotton","sugarcane","coffee","tea"]
  };

  final List<String> soils = [
    "clay loam",
    "alluvial soil",
    "red soil",
    "black soil",
    "sandy soil"
  ];

  final List<String> levels = ["LOW","MEDIUM","HIGH"];

  Widget buildInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) =>
      value == null || value.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> getRecommendation() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      recommendations = [];
      explanation = "";
      nutrientStatus = "";
    });

    try {

      final result = await ApiService.recommendFertilizer({

        "crop": selectedCrop,
        "soil_type": selectedSoil,

        "N_level": nLevel,
        "P_level": pLevel,
        "K_level": kLevel,

        "temperature": double.parse(tempController.text),
        "humidity": double.parse(humidityController.text),
        "ph": double.parse(phController.text),
        "rainfall": double.parse(rainfallController.text),
      });

      setState(() {

        recommendations = result["recommendations"];
        explanation = result["explanation"];
        nutrientStatus = result["nutrient_status"];

      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get recommendation")),
      );

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    tempController.dispose();
    humidityController.dispose();
    rainfallController.dispose();
    phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<String> crops = cropMap[selectedCategory]!;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Fertilizer Recommendation"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              DropdownButtonFormField(
                value: selectedCategory,
                decoration: const InputDecoration(
                    labelText: "Crop Category",
                    border: OutlineInputBorder()),
                items: categories
                    .map((c)=>DropdownMenuItem(value:c,child:Text(c)))
                    .toList(),
                onChanged:(v){
                  setState(() {
                    selectedCategory=v!;
                    selectedCrop=cropMap[v]![0];
                  });
                },
              ),

              const SizedBox(height:16),

              DropdownButtonFormField(
                value:selectedCrop,
                decoration: const InputDecoration(
                    labelText:"Crop",
                    border:OutlineInputBorder()),
                items:crops
                    .map((c)=>DropdownMenuItem(value:c,child:Text(c)))
                    .toList(),
                onChanged:(v){
                  setState(()=>selectedCrop=v!);
                },
              ),

              const SizedBox(height:16),

              DropdownButtonFormField(
                value:selectedSoil,
                decoration: const InputDecoration(
                    labelText:"Soil Type",
                    border:OutlineInputBorder()),
                items:soils
                    .map((s)=>DropdownMenuItem(value:s,child:Text(s)))
                    .toList(),
                onChanged:(v){
                  setState(()=>selectedSoil=v!);
                },
              ),

              const SizedBox(height:20),

              DropdownButtonFormField(
                value:nLevel,
                decoration: const InputDecoration(
                    labelText:"Nitrogen Level",
                    border:OutlineInputBorder()),
                items:levels
                    .map((l)=>DropdownMenuItem(value:l,child:Text(l)))
                    .toList(),
                onChanged:(v)=>setState(()=>nLevel=v!),
              ),

              const SizedBox(height:16),

              DropdownButtonFormField(
                value:pLevel,
                decoration: const InputDecoration(
                    labelText:"Phosphorus Level",
                    border:OutlineInputBorder()),
                items:levels
                    .map((l)=>DropdownMenuItem(value:l,child:Text(l)))
                    .toList(),
                onChanged:(v)=>setState(()=>pLevel=v!),
              ),

              const SizedBox(height:16),

              DropdownButtonFormField(
                value:kLevel,
                decoration: const InputDecoration(
                    labelText:"Potassium Level",
                    border:OutlineInputBorder()),
                items:levels
                    .map((l)=>DropdownMenuItem(value:l,child:Text(l)))
                    .toList(),
                onChanged:(v)=>setState(()=>kLevel=v!),
              ),

              const SizedBox(height:20),

              buildInput("Temperature (°C)", tempController),
              const SizedBox(height:12),

              buildInput("Humidity (%)", humidityController),
              const SizedBox(height:12),

              buildInput("Rainfall (mm)", rainfallController),
              const SizedBox(height:12),

              buildInput("Soil pH", phController),

              const SizedBox(height:25),

              SizedBox(
                width:double.infinity,
                child:ElevatedButton(
                    onPressed:isLoading?null:getRecommendation,
                    child: const Text("Get Fertilizer Recommendation")),
              ),

              const SizedBox(height:30),

              if(isLoading)
                const CircularProgressIndicator(),

              if(recommendations.isNotEmpty)

                Column(

                  crossAxisAlignment:CrossAxisAlignment.start,

                  children:[

                    const Text(
                      "Top Fertilizer Recommendations",
                      style:TextStyle(
                          fontSize:20,
                          fontWeight:FontWeight.bold),
                    ),

                    const SizedBox(height:10),

                    ...recommendations.asMap().entries.map((entry){

                      int index = entry.key;
                      var fert = entry.value;

                      return Card(
                        color: index==0
                            ? Colors.green.shade400
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade700,
                            child: Text("${index+1}"),
                          ),
                          title: Text(fert["fertilizer"]),
                          subtitle: const Text("Recommended fertilizer"),
                          trailing: Text(
                              "${fert["confidence"]}%"),
                        ),
                      );

                    }),

                    const SizedBox(height:20),

                    Text(
                      "Nutrient Status: $nutrientStatus",
                      style:const TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize:16),
                    ),

                    const SizedBox(height:10),

                    Card(
                      color: Colors.green.shade600,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          explanation,
                          style: const TextStyle(fontSize:15),
                        ),
                      ),
                    ),

                  ],
                )

            ],

          ),

        ),

      ),

    );
  }
}