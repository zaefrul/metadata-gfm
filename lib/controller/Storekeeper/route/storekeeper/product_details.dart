import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:photo_view/photo_view.dart';

class MaterialDetails extends StatefulWidget {
  final String id;

  MaterialDetails(this.id);

  @override
  _MaterialDetailsState createState() => _MaterialDetailsState(id);
}

class _MaterialDetailsState extends State<MaterialDetails> {
  final BlocMaterial _bloc;

  _MaterialDetailsState(String id) : this._bloc = BlocMaterial(id);

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _bloc.getInfo(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _bloc == null
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Container(
              child: StreamBuilder<ComplaintMaterial>(
                  stream: _bloc.info$,
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return Container(
                          child: Center(child: CircularProgressIndicator()));

                    final data = snapshot.data;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _Info(data),
                          Divider(color: Colors.black38),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  "List of Images : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                if (data.images.length == 0)
                                  Text("No Images Uploaded"),
                                if (data.images.length > 0)
                                  Text("${data.images.length} File")
                                // IconButton(icon: Icon(Icons.add), onPressed: () {})
                              ],
                            ),
                          ),
                          Images(data.images.toList()),
                          Divider(thickness: 0.5, color: Colors.black38),
                          threshold(_bloc),
                          setMinimum(_bloc),
                          setMaximum(_bloc),
                        ],
                      ),
                    );
                  }),
            ),
    );
  }
}

Widget threshold(BlocMaterial value) => StreamBuilder<int>(
      stream: value.threshold,
      builder: (ctx, snapshot) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Text(
              "Threshold : ",
              style: TextStyle(color: colorTheme4),
            ),
            // IconButton(
            //     icon: Icon(Icons.remove, color: Colors.grey),
            //     onPressed: () =>
            //         snapshot.data != 0 ? value.minusThreshold() : null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 20, color: colorTheme4),
              ),
            ),
            // IconButton(
            //     icon: Icon(Icons.add, color: Colors.grey),
            //     onPressed: () => value.addThreshold()),
          ],
        ),
      ),
    );

Widget setMinimum(BlocMaterial value) => StreamBuilder<int>(
      stream: value.minOrder,
      builder: (ctx, snapshot) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Text(
              "Min Order : ",
              style: TextStyle(color: colorTheme3),
            ),
            // IconButton(
            //     icon: Icon(Icons.remove, color: Colors.grey),
            //     onPressed: () => snapshot.data != 0 ? value.minusMin() : null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 20, color: colorTheme3),
              ),
            ),
            // IconButton(
            //     icon: Icon(Icons.add, color: Colors.grey),
            //     onPressed: () => value.addMin()),
          ],
        ),
      ),
    );

Widget setMaximum(BlocMaterial value) => StreamBuilder<int>(
      stream: value.maxOrder,
      builder: (ctx, snapshot) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Text(
              "Max Order : ",
              style: TextStyle(color: colorTheme3),
            ),
            // IconButton(
            //     icon: Icon(Icons.remove, color: Colors.grey),
            //     onPressed: () => snapshot.data != 0 ? value.minusMax() : null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 20, color: colorTheme3),
              ),
            ),
            // IconButton(
            //     icon: Icon(Icons.add, color: Colors.grey),
            //     onPressed: () => value.addMax()),
          ],
        ),
      ),
    );

class _Info extends StatelessWidget {
  final ComplaintMaterial value;

  _Info(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.30),
        },
        children: <TableRow>[
          row("Category : ", value.assetGroupName),
          row("Type : ", value.itemTypeDesc),
          row("Quantity : ", value.partCount),
          row("Description : ", value.partRemark),
        ],
      ),
    );
  }

  TableRow row(String title, String value) {
    return TableRow(children: [
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(value),
      )),
    ]);
  }
}

class Images extends StatelessWidget {
  final List<ComplaintMaterialImage> items;
  Images(this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            items.length,
            (index) => TextButton(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ViewImage(url: items[index].file),
                      ),
                    ),
                child: Text("$index. ${items[index].title}")),
          )),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(url),
    ));
  }
}
