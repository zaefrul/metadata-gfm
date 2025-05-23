import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:photo_view/photo_view.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_material.dart';

// Dummy implementations for missing classes—you should replace these with your actual implementations.
class ComplaintMaterial {
  final String assetGroupName;
  final String itemTypeDesc;
  final String partCount;
  final String partRemark;
  final List<ComplaintMaterialImage> images;
  ComplaintMaterial({
    required this.assetGroupName,
    required this.itemTypeDesc,
    required this.partCount,
    required this.partRemark,
    required this.images,
  });
}

class ComplaintMaterialImage {
  final String file;
  final String title;
  ComplaintMaterialImage({required this.file, required this.title});
}

class MaterialDetails extends StatefulWidget {
  final String id;

  const MaterialDetails({Key? key, required this.id}) : super(key: key);

  @override
  _MaterialDetailsState createState() => _MaterialDetailsState();
}

class _MaterialDetailsState extends State<MaterialDetails> {
  final BlocMaterial _bloc;

  _MaterialDetailsState() : _bloc = BlocMaterial(""); // Dummy initialization

  // Use a factory constructor to pass the id to the bloc properly.
  factory _MaterialDetailsState.withId(String id) {
    final state = _MaterialDetailsState();
    state._bloc.setId(id);
    return state;
  }

  @override
  void initState() {
    super.initState();
    // If your bloc requires initialization or fetching, do it here.
  }

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
        title: const Text("Material Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _bloc == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              child: StreamBuilder<ComplaintMaterial>(
                  stream: _bloc.info$ as Stream<ComplaintMaterial>?,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _Info(data),
                          const Divider(color: Colors.black38),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12),
                            child: Row(
                              children: [
                                const Text(
                                  "List of Images : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                if (data.images.isEmpty)
                                  const Text("No Images Uploaded")
                                else
                                  Text("${data.images.length} File"),
                                // Optionally add an IconButton if needed.
                              ],
                            ),
                          ),
                          Images(data.images.toList()),
                          const Divider(thickness: 0.5, color: Colors.black38),
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

Widget threshold(BlocMaterial bloc) => StreamBuilder<int>(
      stream: bloc.threshold$,
      builder: (ctx, snapshot) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            const Text(
              "Threshold : ",
              style: TextStyle(color: colorTheme4),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data?.toString() ?? "0",
                style: const TextStyle(fontSize: 20, color: colorTheme4),
              ),
            ),
          ],
        ),
      ),
    );

Widget setMinimum(BlocMaterial bloc) => StreamBuilder<int>(
      stream: bloc.minOrder$,
      builder: (ctx, snapshot) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            const Text(
              "Min Order : ",
              style: TextStyle(color: colorTheme3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data?.toString() ?? "0",
                style: const TextStyle(fontSize: 20, color: colorTheme3),
              ),
            ),
          ],
        ),
      ),
    );

Widget setMaximum(BlocMaterial bloc) => StreamBuilder<int>(
      stream: bloc.maxOrder$,
      builder: (ctx, snapshot) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            const Text(
              "Max Order : ",
              style: TextStyle(color: colorTheme3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                snapshot.data?.toString() ?? "0",
                style: const TextStyle(fontSize: 20, color: colorTheme3),
              ),
            ),
          ],
        ),
      ),
    );

class _Info extends StatelessWidget {
  final ComplaintMaterial value;

  const _Info(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(0.30),
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
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(value),
      ),
    ]);
  }
}

class Images extends StatelessWidget {
  final List<ComplaintMaterialImage> items;

  const Images(this.items, {Key? key}) : super(key: key);

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
            child: Text("$index. ${items[index].title}"),
          ),
        ),
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
