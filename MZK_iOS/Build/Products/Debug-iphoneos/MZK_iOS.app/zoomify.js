
var queryString = function () {
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  } 
    return query_string;
} ();

var imgWidth = queryString.width;
var imgHeight = queryString.height;
var url = queryString.url;

var extent = [0, -imgHeight, imgWidth, 0]

var projection = new ol.proj.Projection({
  units: 'pixels',
  extent: extent
});

var zoomifySource = new ol.source.Zoomify({
  url: url,
  size: [imgWidth, imgHeight],
  projection: projection,
  imageExtent: extent
});

var imageSource = new ol.source.ImageStatic({             
  url: url + "TileGroup0/0-0-0.jpg",
  projection: projection,
  imageExtent: extent
})



var map = new ol.Map({
  layers: [   
      new ol.layer.Image({
        source: imageSource
      }),
      new ol.layer.Tile({
        source: zoomifySource
      })
  ],
  interactions: ol.interaction.defaults({pinchRotate:false}),
  controls:[],
  target: 'image-target',
  view: new ol.View({
    projection: projection,
    center: ol.extent.getCenter(extent),
    zoom: .9,
    extent: extent
                    
  })
  
});

