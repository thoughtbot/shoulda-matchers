require 'spec_helper'
require 'shoulda/matchers/util/word_wrap'

describe Shoulda::Matchers, ".word_wrap" do
  it "can wrap a simple paragraph" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "does not split words up when wrapping" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lusciousness, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
lusciousness, ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "considers punctuation as part of a word" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luscious, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
luscious, ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "does not break at the maximum line length, but afterward" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luscius, ipsum sit amet efficitur feugiat
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luscius,
ipsum sit amet efficitur feugiat
    MESSAGE
  end

  it "re-wraps entire paragraphs" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet,
consectetur adipiscing elit.
Aenean luctus,
ipsum sit amet efficitur feugiat,
dolor mauris fringilla erat, sed posuere diam ex ut velit.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed
posuere diam ex ut velit.
    MESSAGE
  end

  it "can wrap multiple paragraphs" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

Etiam ultrices cursus ligula eget feugiat. Vestibulum eget tincidunt risus, non faucibus sem. 
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus,
ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed
posuere diam ex ut velit.

Etiam ultrices cursus ligula eget feugiat. Vestibulum eget tincidunt
risus, non faucibus sem.
    MESSAGE
  end

  it "can wrap a bulleted list" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
  luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat,
  sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE
  end

  it "re-wraps bulleted lists" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
* Lorem ipsum dolor sit amet,
  consectetur adipiscing elit.
  Aenean luctus,
  ipsum sit amet efficitur feugiat,
  dolor mauris fringilla erat,
  sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
  luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat,
  sed posuere diam ex ut velit.
* And the beat goes on.
    MESSAGE
  end

  it "can wrap a numbered list" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE
  end

  it "re-wraps numbered lists" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
1. Lorem ipsum dolor sit amet,
   consectetur adipiscing elit.
   Aenean luctus,
   ipsum sit amet efficitur feugiat,
   dolor mauris fringilla erat,
   sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2. And the beat goes on.
    MESSAGE
  end

  it "can wrap a numbered list, using x) instead of x. as the leader" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE
  end

  it "re-wraps numbered lists using x) instead of x. as the leader" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
1) Lorem ipsum dolor sit amet,
   consectetur adipiscing elit.
   Aenean luctus,
   ipsum sit amet efficitur feugiat,
   dolor mauris fringilla erat,
   sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
1) Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
   luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla
   erat, sed posuere diam ex ut velit.
2) And the beat goes on.
    MESSAGE
  end

  it "doesn't mess with indented blocks" do
    wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Some text is gonna go here.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

And now we return.
    MESSAGE

    expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Some text is gonna go here.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat, dolor mauris fringilla erat, sed posuere diam ex ut velit.

And now we return.
    MESSAGE
  end

  context "given a string with a word longer than the max character limit" do
    context "which stands on its own" do
      it "simply returns the string" do
        wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Foo bar baz and stuff and things Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
        MESSAGE

        expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Foo bar baz and stuff and things
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
        MESSAGE
      end
    end

    context "which is preceded by some text" do
      it "leaves the word on its own line" do
        wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Foo bar baz and stuff and things Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
        MESSAGE

        expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Foo bar baz and stuff and things
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
        MESSAGE
      end
    end

    context "which is followed by some text" do
      it "leaves the word on its own line" do
        wrapped_message = described_class.word_wrap(<<-MESSAGE.rstrip)
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat, and something goes after this
        MESSAGE

        expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
Loremipsumdolorsitamet,consecteturadipiscingelit.Aeneanluctus,ipsumsitametefficiturfeugiat,
and something goes after this
        MESSAGE
      end
    end
  end

  context "when :indent is given" do
    it "uses the given indentation level when determining where to wrap lines" do
      wrapped_message = described_class.word_wrap(<<-MESSAGE.strip, indent: 2)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean luctus, ipsum sit amet efficitur feugiat
      MESSAGE

      expect(wrapped_message).to eq(<<-MESSAGE.rstrip)
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
  luctus, ipsum sit amet efficitur feugiat
      MESSAGE
    end
  end
end
