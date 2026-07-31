enum InputModality {
  text('text'),
  image('image'),
  file('file'),
  audio('audio'),
  video('video'),
  realtime('realtime');

  const InputModality(this.value);

  final String value;
}

enum OutputModality {
  text('text'),
  image('image'),
  speech('speech'),
  audio('audio'),
  realtime('realtime'),
  music('music'),
  video('video'),
  multi('multi');

  const OutputModality(this.value);

  final String value;
}
