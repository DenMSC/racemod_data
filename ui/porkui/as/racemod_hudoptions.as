HUDOption@[] parseHUDOptions( String file )
{
  String titleToken;
  String cvarToken;
  String valueToken;
  HUDOption@[] options;
  // split by \n\n
  String@[] raw_options = StringUtils::Split(file, "\n\n");
  for ( uint i = 0; i < raw_options.length; i++ ) {
    String raw_option = raw_options[i];

    uint index = 0;
    HUDOption@ option = HUDOption();

    titleToken = raw_option.getToken(index++);
    if ( titleToken.length() == 0 )
      break;
    option.title = titleToken;

    cvarToken = raw_option.getToken(index++);
    if ( cvarToken.length() == 0 )
      break;
    option.cvar = cvarToken;

    while ( true ) {
      HUDOptionChoice@ choice = HUDOptionChoice();

      valueToken = raw_option.getToken(index++);
      if ( valueToken.length() == 0 )
        break;
      choice.value = valueToken;

      titleToken = raw_option.getToken(index++);
      if ( titleToken.length() == 0 )
        break;
      choice.title = titleToken;

      option.options.push_back(choice);
    }
    options.push_back(option);
  }

  return options;
}

class HUDOption
{
  String title;
  String cvar;
  HUDOptionChoice@[] options;
}

class HUDOptionChoice
{
  String value;
  String title;
}