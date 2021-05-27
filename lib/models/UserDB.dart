class UserDB {
  List<Users> users;
  UserDB({this.users});

  UserDB.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = new List<Users>();
      json['users'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  List<String> amigos;
  List<Fotos> fotos;
  String pfp;
  userLocation location;
  String email;
  String name;

  Users({this.amigos, this.fotos, this.pfp, this.location, this.name, this.email});

  Users.fromJson(Map<String, dynamic> json) {
    amigos = json['amigos'].cast<String>();
    if (json['fotos'] != null) {
      fotos = new List<Fotos>();
      json['fotos'].forEach((v) {
        fotos.add(new Fotos.fromJson(v));
      });
    }
    pfp = json['pfp'];
    email = json['email'];
    location = json['location'] != null
        ? new userLocation.fromJson(json['location'])
        : null;
    name = json['name'];
  }

  toString() {
    return '{ name:' + name + ', email: ' + email + ', amigos: '+ amigos.toString() + ', fotos: ' + fotos.toString() + ', pfp: ' + pfp + ', location: ' + location.toString() +' }';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amigos'] = this.amigos;
    if (this.fotos != null) {
      data['fotos'] = this.fotos.map((v) => v.toJson()).toList();
    }
    data['pfp'] = this.pfp;
    data['email'] = this.email;
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    data['name'] = this.name;
    return data;
  }
}

class Fotos {
  String nombre;
  int timestamp;

  Fotos({this.nombre, this.timestamp});

  Fotos.fromJson(Map<String, dynamic> json) {
    nombre = json['nombre'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class userLocation {
  double lat;
  double long;

  userLocation({this.lat, this.long});

  userLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;
    return data;
  }
}