application nodejs_app (
  String $app_name,
  String $app_version,
  String $app_repo,
  Variant[String,Undef] $vcsroot = undef,
){

  nodejs_app::appserver { $name:
    app_name    => $app_name,
    app_version => $app_version,
    app_repo    => $app_repo,
    vcsroot     => $vcsroot,
    export      => Http[$name],
  }

}
