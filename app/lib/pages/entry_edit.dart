import 'package:app/scoped_models/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

class EntryEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _EntryEditPageState();
  }
}

class _EntryEditPageState extends State<EntryEditPage> {
  final Map<String, dynamic> _formData = {
    "title": null,
    "description": null,
    "amount": 0.0,
    "image": "assets/food.jpg",
    "transactionType": "debit"
  };

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, model) {
        return model.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RaisedButton(
                shape: ShapeBorder.lerp(null, null, 2.6),
                child: Text('SAVE'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                onPressed: () => _submitForm(model.addEntry, -1));
      },
    );
  }

  Widget _buildPageContent(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            child: Form(
                key: _formState,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                  children: <Widget>[
                    _buildTitleTextField(),
                    _buildDescriptionTextField(),
                    _buildTypeofEntry(),
                    _buildAmountTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildSubmitButton()
                  ],
                ))));
  }

  Widget _buildTitleTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Entry Title'),
      initialValue: '',
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return "Title Required & should be 5+ characters";
        }
      },
      onSaved: (String value) {
        _formData["title"] = value;
      },
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Entry Description'),
      initialValue: '',
      maxLines: 4,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Description Required & should be 5+ characters';
        }
      },
      onSaved: (String value) {
        _formData["description"] = value;
      },
    );
  }

  List<String> _transactionTypes = <String>['DEBIT', 'CREDIT'];
  String _transactionType = 'DEBIT';

  Widget _buildTypeofEntry() {
    return FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Transaction Type',
          ),
          isEmpty: _transactionType == '',
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              value: _transactionType,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  _formData['transactionType'] = newValue;
                  _transactionType = newValue;
                  state.didChange(newValue);
                });
              },
              items: _transactionTypes.map((String value) {
                return new DropdownMenuItem(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Entry Amount'),
      keyboardType: TextInputType.number,
      initialValue: '',
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return "Amount required and should be a number";
        }
      },
      onSaved: (String value) {
        _formData["amount"] = value;
      },
    );
  }

  void _submitForm(Function addEntry, [int selectedEntryIndex]) {
    if (!_formState.currentState.validate()) return;
    _formState.currentState.save();
    if (selectedEntryIndex == -1)
      addEntry(_formData['title'], _formData['description'], _formData['image'],
              double.parse(_formData['amount']), _formData['transactionType'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/dashboard').then((_) {
            // setSelectedProduct(null);
          });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Something went wrong"),
                  content: Text("Please try again"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Okay"),
                      onPressed: Navigator.of(context).pop,
                    )
                  ],
                );
              });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModel<MainModel>(
        model: new MainModel(),
        child:
            ScopedModelDescendant<MainModel>(builder: (context, child, model) {
          Widget pageContent = _buildPageContent(context);
          print("------");
          // print(model.user.email);
          // print(model.user.userId);
          return pageContent;
        }));
  }
}
