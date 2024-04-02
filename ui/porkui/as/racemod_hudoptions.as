HUDOption@[] parseHUDOptions( String file )
{
  String typeToken;
  String titleToken;
  String cvarToken;
  String valueToken;
  HUDOption@[] options;
  // split by \n\n
  String@[] raw_options = StringUtils::Split(file, "\n\n");
  for ( uint i = 0; i < raw_options.length(); i++ )
  {
    String raw_option = raw_options[i];

    uint index = 0;

    typeToken = raw_option.getToken(index++);
    if ( typeToken.length() == 0 )
      break;

    HUDOption@ option;
    if ( typeToken == "checkbox" )
    {
      @option = HUDOptionCheckbox();
    } else if ( typeToken == "dropdown" )
    {
      @option = HUDOptionDropdown();
    } else if ( typeToken == "checkboxes" )
    {
      @option = HUDOptionCheckboxes();
    } else {
      break;
    }

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
      choice.value = valueToken.toInt();

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
  String render() {return "";}
}

class HUDOptionChoice
{
  int value;
  String title;
}

class HUDOptionCheckbox : HUDOption
{
  String render()
  {
    return
    '<div class="title">' + this.title + '</div>' +
    '<input cvar="' + this.cvar + '" type="checkbox" realtime="1"/>';
  }
}

class HUDOptionDropdown : HUDOption
{
  String render()
  {
    String rml = "";
    rml += '<div class="title">' + this.title + '</div>';
    rml += '<select cvar="' + this.cvar + '" realtime="1">';
    for ( uint j = 0; j < this.options.length(); j++ )
    {
      HUDOptionChoice@ choice = @this.options[j];
      rml += '<option value="' + choice.value + '">' + choice.title + '</option>';
    }
    rml += '</select>';
    return rml;
  }
}

HUDOptionCheckboxes@[] checkboxes;
class HUDOptionCheckboxes : HUDOption
{
  HUDOptionCheckboxes()
  {
    checkboxes.push_back(@this);
  }

  void click( Element @self ) {
    Cvar checkboxcvar(this.cvar, "0", ::CVAR_ARCHIVE);
    int cvarValue = checkboxcvar.integer;
    int value = self.getAttr('value', '0').toInt();
    bool active = !self.hasAttr('checked');

    int currSum = 0;
    int defaultSum = 0;
    for ( uint i = 0; i < this.options.length(); i++ )
    {
      HUDOptionChoice@ choice = @this.options[i];

      if ( choice.value > 0 ) // default
      {
        defaultSum += abs(choice.value);
        if ( cvarValue == 1 ) {
          currSum += abs(choice.value);
        }
      }

      if ( (cvarValue & abs(choice.value)) != 0 )
      {
        currSum |= abs(choice.value);
      }
    }

    if ( active )
    {
      currSum |= abs(value);
    } else {
      currSum &= ~abs(value);
    }

    if ( currSum == defaultSum ) {
      checkboxcvar.set(1);
    } else {
      checkboxcvar.set(currSum);
    }
  }

  String render()
  {
    Cvar checkboxcvar(this.cvar, "0", ::CVAR_ARCHIVE);
    int cvarValue = checkboxcvar.integer;
    String rml = "";
    for ( uint i = 0; i < this.options.length(); i++ )
    {
      HUDOptionChoice@ choice = @this.options[i];
      bool active = (cvarValue & abs(choice.value)) != 0;
      if ( cvarValue == 1 ) {
        active = choice.value > 0;
      }

      rml += '<div class="title">' + choice.title + '</div>';
      rml += '<input checkboxcvar="' + this.cvar + '"value="' + choice.value +
             '" type="checkbox" onclick="onCheckboxes(self);" ' +
             (active ? 'checked' : '') + '/>';
    }
    return rml;
  }
}

void onCheckboxes( Element @self)
{

  String cvar = self.getAttr('checkboxcvar', '');
  for ( uint i = 0; i < checkboxes.length(); i++ )
  {
    if ( checkboxes[i].cvar == cvar ) {
      checkboxes[i].click(self);
      return;
    }
  }
}