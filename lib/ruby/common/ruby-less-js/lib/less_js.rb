require 'execjs'

module LessJs
  class ParseError < StandardError; end

  module Source
    def self.version
      @version ||= "1.4.1"
    end

    def self.context
      @context ||= ExecJS.compile <<-EOS
        
        var less=require('#{File.join(File.dirname(__FILE__),'less.js','lib','less')}')
        function compile(data,options){
          var parser = new(less.Parser)(options);
          var result
          parser.parse(data, function (err, tree) {
              var css;
              if(err == null)
                css = tree.toCSS(options);
              result=[err, css];
            }
          );
          return result;
        };
      EOS
    end
  end

  class << self
    def version
      Source.version
    end

    # Compile a script (String or IO) to CSS.
    def compile(script, options = {})
      script = script.read if script.respond_to?(:read)
      options[:syncImport]= true

      error, data = Source.context.call('compile', script , options)
      if error
        raise ParseError, error.inspect
      else
        data
      end
    end
  end
end
