require 'spec_helper'
require 'shoulda/matchers/util/word_wrap'

describe Shoulda::Matchers, ".word_wrap" do
  it "can wrap a simple paragraph" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "does not split words up when wrapping" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lusciousness, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
lusciousness, ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "considers punctuation as part of a word" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luscious, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
luscious, ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "re-wraps entire paragraphs" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
Lorem ipsum dolor sit amet,
consectetur adipiscing elit.
Aenean luctus,
ipsum sit amet efficitur feugiat,
dolor mauris fringilla erat, sed posuere diam ex ut velit.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed
posuere diam ex ut velit.
    MESSAGE
  end

  it "can wrap multiple paragraphs" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

Etiam ultrices cursus ligula eget feugiat. Vestibulum eget tincidunt risus, non faucibus sem. 
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed
posuere diam ex ut velit.

Etiam ultrices cursus ligula eget feugiat. Vestibulum eget tincidunt
risus, non faucibus sem.
    MESSAGE
  end

  it "can wrap a bulleted list" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
  luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
  erat, sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE
  end

  it "re-wraps bulleted lists" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
* Lorem ipsum dolor sit amet,
  consectetur adipiscing elit.
  Aenean luctus,
  ipsum sit amet efficitur feugiat,
  dolor mauris fringilla erat,
  sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
  luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
  erat, sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE
  end

  it "can wrap a numbered list" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE
  end

  it "re-wraps numbered lists" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
1. Lorem ipsum dolor sit amet,
   consectetur adipiscing elit.
   Aenean luctus,
   ipsum sit amet efficitur feugiat,
   dolor mauris fringilla erat,
   sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE
  end

  it "can wrap a numbered list, using x) instead of x. as the leader" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE
  end

  it "re-wraps numbered lists using x) instead of x. as the leader" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
1) Lorem ipsum dolor sit amet,
   consectetur adipiscing elit.
   Aenean luctus,
   ipsum sit amet efficitur feugiat,
   dolor mauris fringilla erat,
   sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE
  end

  it "doesn't mess with indented blocks" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
Some text is gonna go here.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

And now we return.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Some text is gonna go here.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

And now we return.
    MESSAGE
  end

  it "doesn't get stuck trying to wrap a line that can't be wrapped" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE)
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.strip)
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
    MESSAGE
  end
end
