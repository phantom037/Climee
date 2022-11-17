import 'package:flutter/material.dart';

const kTempTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 50.0,
);

const kMessageTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 40.0,
);

const kButtonTextStyle = TextStyle(
  fontSize: 30.0,
  color: Colors.yellow,
  fontFamily: 'Spartan MB',
);

const kConditionTextStyle = TextStyle(
  fontSize: 50.0,
);

const kDetailTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 25,
);

const kSubDetailTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 15,
);

const kForecastStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 12,
);

//Large Screen
const kTempTextStyleLarge = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 100.0,
);

const kConditionTextStyleLarge = TextStyle(
  fontSize: 100.0,
);

const kDetailTextStyleLarge = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 30,
);

const kSubDetailTextStyleLarge = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 20,
);

const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
  ), //Icon
  hintText: 'Enter City Name',
  hintStyle: TextStyle(
    color: Colors.grey,
  ), // Text Style
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ), // OutlineInputBorder
); //InputDecoration
