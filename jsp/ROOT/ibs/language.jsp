<%!
	private static Sentence[] sentences;
	private static Vector vSent;
	private static int SI(Sentence sentence) {
		if (vSent == null) vSent = new Vector(100);
		vSent.addElement(sentence);
		return vSent.size() - 1;
	}
  private static int SI(String st1) {
    return SI(new Sentence(st1));
  }
  private static int SI(String st1, String st2) {
    return SI(new Sentence(st1, st2));
  }
  private static int SI(String st1, String st2, String st3) {
    return SI(new Sentence(st1, st2, st3));
  }
  private static int SI(String st1, String st2, String st3, String st4) {
    return SI(new Sentence(st1, st2, st3, st4));
  }
	static 
	{
		if (vSent != null) {
      sentences = new Sentence[vSent.size()];
      for(int i = 0; i < vSent.size(); i++)
        sentences[i] = (Sentence)vSent.elementAt(i);
      vSent = null;
    }
	}
%>