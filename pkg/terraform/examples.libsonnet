local tf = import './main.libsonnet';
local p = import 'pkg/main.libsonnet';

p.ex({}, {
  Format: p.ex({
    example:
      tf.Cfg(
        tf.Output('example', {
          value: tf.Format('Hello %s!', [tf.jsonencode({ foo: 'bar' })]),
        }),
      ),
    expected: [
      {
        output: {
          example: {
            value: 'Hello ${jsonencode({"foo":"bar"})}!',
          },
        },
      },
    ],
  }),
  Variable: p.ex({
    example:
      tf.Cfg(
        tf.Variable('example', {
          default: 'hello',
        })
      ),
    expected: [
      {
        variable: {
          example: {
            default: 'hello',
          },
        },
      },
    ],
  }),
  Output: p.ex({
    example:
      local example = tf.Variable('example', {
        default: 'hello',
      });
      tf.Cfg(
        tf.Output('example2', {
          value: example,
        }),
      ),
    expected: [
      {
        output: {
          example2: {
            value: '${var.example}',
          },
        },
      },
      {
        variable: {
          example: {
            default: 'hello',
          },
        },
      },
    ],
  }),
  Local: p.ex({
    example:
      local example = tf.Local('example', 'hello');
      tf.Cfg(
        tf.Local('example2', example),
      ),
    expected: [
      {
        locals: {
          example: 'hello',
        },
      },
      {
        locals: {
          example2: '${local.example}',
        },
      },
    ],
  }),
  Module: p.ex({
    example:
      tf.Cfg(
        tf.Module('example', {
          source: '../tests/example',
        }),
      ),
    expected: [
      {
        module: {
          example: {
            source: '../tests/example',
          },
        },
      },
    ],
  }),
  If: p.ex({
    example:
      local var = tf.Local('var', false);
      tf.Cfg(
        tf.Output('example', {
          value: tf.If(tf.eq(true, var)).Then('a').Else('b'),
        }),
      ),
    expected: [
      {
        locals: {
          var: false,
        },
      },
      {
        output: {
          example: {
            value: '${true == local.var ? "a" : "b"}',
          },
        },
      },
    ],
  }),
  For: p.ex([{
    name: 'variable',
    example:
      local var = tf.Local('var', ['a', 'b', 'c']);
      tf.Cfg(
        tf.Output('example', {
          value: tf.For('s').In(var).List(function(s) tf.upper(s)),
        }),
      ),
    expected: [
      {
        locals: {
          var: [
            'a',
            'b',
            'c',
          ],
        },
      },
      {
        output: {
          example: {
            value: '${[for s in local.var: upper(s)]}',
          },
        },
      },
    ],
  }, {
    name: 'index',
    example:
      tf.Cfg(
        tf.Output('example', {
          value: tf.For('i', 's').In([1, 2, 3]).List(function(i, s) { index: i, value: s }),
        }),
      ),
    expected: [
      {
        output: {
          example: {
            value: '${[for i, s in [1,2,3]: {"index":i,"value":s}]}',
          },
        },
      },
    ],
  }, {
    name: 'map to list',
    example:
      tf.Cfg(
        tf.Output('example', {
          value: tf.For('k', 'v').In({ foo: 'a', bar: 'b' }).List(function(k, v) { key: k, value: v }),
        }),
      ),
    expected: [
      {
        output: {
          example: {
            value: '${[for k, v in {"bar":"b","foo":"a"}: {"key":k,"value":v}]}',
          },
        },
      },
    ],
  }, {
    name: 'list to map',
    example:
      tf.Cfg(
        tf.Output('example', {
          value: tf.For('s').In(['a', 'b', 'c']).Map(function(s) [s, tf.upper(s)]),
        }),
      ),
    expected: [
      {
        output: {
          example: {
            value: '${{for s in ["a","b","c"]: s => upper(s) }}',
          },
        },
      },
    ],
  }, {
    name: 'map to map',
    example:
      tf.Cfg(
        tf.Output('example', {
          value: tf.For('k', 'v').In({ foo: 'a', bar: 'b' }).Map(function(k, v) [v, k]),
        }),
      ),
    expected: [
      {
        output: {
          example: {
            value: '${{for k, v in {"bar":"b","foo":"a"}: v => k }}',
          },
        },
      },
    ],
  }]),
})
