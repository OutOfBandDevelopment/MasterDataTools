using CommandLine;
using MyDataTools.Import.Properties;
using System;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using static System.Data.ConnectionState;
using static System.Data.SqlDbType;
using static System.IO.SearchOption;

namespace MyDataTools.Import
{
    class Program
    {
        static void Main(string[] args)
        {
            Parser.Default
                  .ParseArguments<CommandOptions>(args)
                  .WithParsed(o => ExecuteAsync(o).Wait())
                  ;
        }

        private static async Task ExecuteAsync(CommandOptions opt)
        {
            var pattern = new Regex(opt.Pattern);
            var files = from f in Directory.EnumerateFiles(opt.SourcePath, opt.Filter, opt.Recursive ? AllDirectories : TopDirectoryOnly)
                        let matched = pattern.Match(f)
                        where matched.Success
                        let schema = matched.Groups["schema"].Value
                        let table = matched.Groups["table"].Value
                        select new ReferenceFile
                        {
                            RealtivePath = f,
                            FullPath = Path.GetFullPath(f),
                            Schema = schema,
                            Table = table,
                        };

            var beforeAndAfter = files.Select(f => GetBeforeAndAfterAsync(opt, f));
            var results = await Task.WhenAll(beforeAndAfter);
        }

        private static async Task<BeforeAndAfter> GetBeforeAndAfterAsync(CommandOptions opt, ReferenceFile file)
        {
            using var conn = new SqlConnection(opt.ConnectionString);
            if (conn.State != Open) await conn.OpenAsync();

            //TODO: query before and after by schema/table

            using var cmd = new SqlCommand(Resources.BeforeAfterScripts, conn);
            cmd.Parameters.Add(nameof(ReferenceFile.Schema), NVarChar).Value = file.Schema;
            cmd.Parameters.Add(nameof(ReferenceFile.Table), NVarChar).Value = file.Table;

            using var reader = await cmd.ExecuteReaderAsync();

            var before = new StringBuilder();
            var after = new StringBuilder();

            while (await reader.ReadAsync())
            {
                before.Append(reader["Before"] as string);
                after.Append(reader["After"] as string);
            }

            return new BeforeAndAfter
            {
                File = file,
                Before = before.ToString(),
                After = after.ToString(),
            };
        }
    }
}
