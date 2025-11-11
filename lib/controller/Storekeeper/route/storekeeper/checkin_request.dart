import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_checkin.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toast/toast.dart';
import '../../../../main.dart';

class CheckinRequest extends StatefulWidget {
  const CheckinRequest({super.key});

  @override
  _CheckinRequestState createState() => _CheckinRequestState();
}

class _CheckinRequestState extends State<CheckinRequest> {
  final BlocCheckin _controller = BlocCheckin();
  List<ComplaintDStore> stores = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("CheckinRequest: didChangeDependencies called");
    _controller
        .fetchStore(context)
        .then((value) {
          print("CheckinRequest: fetchStore completed, got ${value.length} stores");
          if (mounted) {
            setState(() => stores = value);
          }
        })
        .catchError((error) {
          print("CheckinRequest: fetchStore error: $error");
          if (mounted) {
            Toast.show("Failed to load stores: $error", duration: 4);
          }
        });
    
    // Track dialog state to prevent double pops
    bool isDialogOpen = false;
    
    _controller.loadingState$.listen((event) {
      print("CheckinRequest: loadingState changed to: $event, dialog open: $isDialogOpen");
      if (event == true && !isDialogOpen) {
        isDialogOpen = true;
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (_) => WillPopScope(
            onWillPop: () async => false,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      } else if (event == false && isDialogOpen) {
        print("CheckinRequest: Closing loading dialog");
        isDialogOpen = false;
        if (Navigator.canPop(navigatorKey.currentContext!)) {
          Navigator.pop(navigatorKey.currentContext!);
        }
      }
    });
    _controller.err$.listen((event) {
      print("CheckinRequest: Error received: $event");
      if (mounted) {
        Toast.show(event, duration: 4);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Check In Information"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _filter,
          _Info(_controller),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Text(
                  "List of DO attachments : ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _controller.createUploadItem(context),
                )
              ],
            ),
          ),
          AttachmentsDO(_controller),
          Divider(color: Colors.black38),
          _ListView(_controller),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _addButton(context),
          SizedBox(width: 12),
          _submitButton(context),
        ],
      ),
    );
  }

  Widget _addButton(BuildContext context) => FloatingActionButton(
      heroTag: "add_material_fab",
      backgroundColor: colorTheme2,
      child: Icon(Icons.add),
      onPressed: () {
        print("CheckinRequest: Opening add material page");
        Navigator.pushNamed(context, routeAddStockIn).then((value) {
          print("CheckinRequest: Add material returned with value type: ${value.runtimeType}");
          print("CheckinRequest: Add material returned value: $value");
          if (value != null && value is Item) {
            print("CheckinRequest: Adding item to controller");
            _controller.material = value;
          } else if (value != null) {
            print("CheckinRequest: ERROR - Received non-Item value: ${value.runtimeType}");
            Toast.show("Invalid item format received", duration: 3);
          }
        });
      });

  Widget _submitButton(BuildContext context) => FloatingActionButton.extended(
      heroTag: "submit_checkin_fab",
      backgroundColor: colorTheme2,
      label: Text("Submit"),
      onPressed: () {
        print("CheckinRequest: Submit button pressed");
        _controller.submit(context).then((value) {
          print("CheckinRequest: Submit successful, navigating back");
          // Show toast BEFORE navigation to prevent deactivated widget error
          if (mounted) {
            Toast.show("Checkin Successful");
            // Small delay to ensure toast is visible before navigation
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        }).catchError((err) {
          print("CheckinRequest: Submit error: $err");
          if (mounted) {
            Toast.show(err.toString(), duration: 4);
          }
          return null;
        });
      });

  Widget get _filter => StreamBuilder<ComplaintDStore>(
      stream: _controller.store$,
      builder: (context, snapshot) {
        // Find matching value in stores list
        ComplaintDStore? selectedStore;
        if (snapshot.hasData && snapshot.data != null) {
          selectedStore = stores.firstWhere(
            (store) => store.itemId == snapshot.data?.itemId,
            orElse: () => stores.isNotEmpty ? stores.first : snapshot.data!,
          );
        }
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                "Store :  ",
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<ComplaintDStore>(
                underline: Container(),
                value: selectedStore,
                hint: Text("Select Store"),
                onChanged: (ComplaintDStore? newValue) {
                  if (newValue != null) {
                    _controller.store = newValue;
                  }
                },
                items: stores.map<DropdownMenuItem<ComplaintDStore>>(
                    (ComplaintDStore value) {
                  return DropdownMenuItem<ComplaintDStore>(
                    value: value,
                    child: Text(value.itemName ?? 'Unknown'),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      });
}

class _Info extends StatelessWidget {
  final BlocCheckin _controller;

  const _Info(this._controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller.doNoCtrl,
            decoration: InputDecoration(labelText: "Do No :"),
          ),
          TextField(
            controller: _controller.supplierCtrl,
            decoration: InputDecoration(labelText: "Supplier Name :"),
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final BlocCheckin controller;

  const _ListView(this.controller);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
        stream: controller.materials$,
        builder: (context, snapshot) {
          return ListView(
            padding: EdgeInsets.only(bottom: 20),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: List.generate(
              (snapshot.data ?? []).length,
              (index) => _Material(index + 1, snapshot.data![index],
                  () {
                    final item = snapshot.data?[index];
                    if (item != null) {
                      controller.removeMaterial(item);
                    }
                  }),
            ),
          );
        });
  }
}

class _Material extends StatelessWidget {
  final Item data;
  final int index;
  final Function onDeleteItem;

  const _Material(this.index, this.data, this.onDeleteItem);

  @override
  Widget build(BuildContext context) {
    final String doItemCost = data.itemPrice;
    final String doItemTotal = data.itemQuantity;
    final String doItemTotalCost =
        (int.parse(data.itemQuantity) * double.parse(data.itemPrice))
            .toStringAsFixed(2);
    final String doItemValidity = data.doItemValidity;
    final String doItemWarranty = data.doItemWarranty;
    final String doNo = data.itemName;

    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          '$index.  $doNo',
          overflow: TextOverflow.fade,
        ),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        text(value: "RM $doItemCost", top: 8.0),
        text(value: "Quantity : $doItemTotal"),
        text(value: "Total Cost : RM $doItemTotalCost"),
      ]),
      children: [
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
            child: Text('Validity : $doItemValidity'),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text('Warranty : $doItemWarranty'),
          ),
        ),
        SizedBox(height: 12),
        Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: colorTheme4,
              ),
              onPressed: () {
                onDeleteItem();
                Toast.show("Item Removed");
              },
            )),
      ],
    );
  }

  Widget text({required String value, double top = 3.0, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: color ?? colorTheme3),
      ),
    );
  }
}

class AttachmentsDO extends StatelessWidget {
  final BlocCheckin controller;
  const AttachmentsDO(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<List<File>>(
          stream: controller.do$,
          builder: (context, snapshot) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  (snapshot.data ?? []).length,
                  (index) => TextButton(
                      onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  snapshot.data != null
                                      ? ViewImage(key: UniqueKey(), file: snapshot.data![index])
                                      : SizedBox.shrink(),
                            ),
                          ),
                      child: Text("$index. ${snapshot.data?[index].path ?? 'Unknown Path'}")),
                ));
          }),
    );
  }
}

class ViewImage extends StatelessWidget {
  final File file;

  const ViewImage({required Key key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: FileImage(File(file.path)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: BoxDecoration(color: Colors.black),
      ),
    );
  }
}
