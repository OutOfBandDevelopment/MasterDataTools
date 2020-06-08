using CommandLine;
using MyDataTools.Import.Properties;
using System;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
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

        private static async Task ExecuteAsync(CommandOptions options)
        {
            var pattern = new Regex(options.Pattern);
            var files = from f in Directory.EnumerateFiles(options.SourcePath, options.Filter, options.Recursive ? AllDirectories : TopDirectoryOnly)
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

            var beforeAndAfter = await Task.WhenAll(files.Select(f => GetBeforeAndAfterAsync(options, f)));
            var mergeScripts = await Task.WhenAll(beforeAndAfter.Select(f => GetMergeScriptAsync(options, f)));

            await Task.WhenAll(mergeScripts.Select(f => CreateScriptAsync(options, f)));
        }

        private static async Task CreateScriptAsync(CommandOptions options, MergeScriptModel source)
        {
            Console.WriteLine($"[{source.Schema}].[{source.Table}]{new string('+', (int)Math.Ceiling(new FileInfo(source.FullPath).Length / (1024m * 32m)))}");

            var content =  await File.ReadAllTextAsync(source.FullPath);

            var builder = new StringBuilder();

            builder.AppendFormat("DECLARE @json AS NVARCHAR(MAX) = '{0}';", content?.Replace("'", "''")).AppendLine().AppendLine();

            if (!string.IsNullOrWhiteSpace(source.Before))
                builder.AppendLine(source.Before).AppendLine();

            if (!string.IsNullOrWhiteSpace(source.Body))
                builder.AppendLine(source.Body).AppendLine();

            if (!string.IsNullOrWhiteSpace(source.After))
                builder.AppendLine(source.After).AppendLine();

            var outFileName = Path.Combine(options.OutputPath, Path.GetFileNameWithoutExtension(source.FullPath) + ".sql");
            var directory = Path.GetDirectoryName(outFileName);
            if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);

            File.WriteAllText(outFileName, builder.ToString());
        }

        private static async Task<MergeScriptModel> GetMergeScriptAsync(CommandOptions options, BeforeAndAfter source)
        {
            Console.WriteLine($"[{source.Schema}].[{source.Table}]: Building merge script");
            using var conn = new SqlConnection(options.ConnectionString);
            if (conn.State != Open) await conn.OpenAsync();

            //TODO: query before and after by schema/table

            using var cmd = new SqlCommand(Resources.BuildMerge, conn);
            cmd.Parameters.Add(nameof(ReferenceFile.Schema), NVarChar).Value = source.Schema;
            cmd.Parameters.Add(nameof(ReferenceFile.Table), NVarChar).Value = source.Table;

            cmd.Parameters.Add(nameof(CommandOptions.AddMissing), Bit).Value = options.AddMissing;
            cmd.Parameters.Add(nameof(CommandOptions.Cleanup), Bit).Value = options.Cleanup;
            cmd.Parameters.Add("Output", Bit).Value = false;


            using var reader = await cmd.ExecuteReaderAsync();

            var body = new StringBuilder();

            while (await reader.ReadAsync())
            {
                body.Append(reader[0] as string);
            }

            return new MergeScriptModel
            {
                RealtivePath = source.RealtivePath,
                FullPath = source.FullPath,

                Schema = source.Schema,
                Table = source.Table,

                Before = source.Before,
                After = source.After,

                Body = body.ToString(),
            };
        }

        private static async Task<BeforeAndAfter> GetBeforeAndAfterAsync(CommandOptions options, ReferenceFile source)
        {
            Console.WriteLine($"[{source.Schema}].[{source.Table}]: Checking constraints and indexes");
            using var conn = new SqlConnection(options.ConnectionString);
            if (conn.State != Open) await conn.OpenAsync();

            //TODO: query before and after by schema/table

            using var cmd = new SqlCommand(Resources.BeforeAfterScripts, conn);
            cmd.Parameters.Add(nameof(ReferenceFile.Schema), NVarChar).Value = source.Schema;
            cmd.Parameters.Add(nameof(ReferenceFile.Table), NVarChar).Value = source.Table;

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
                RealtivePath = source.RealtivePath,
                FullPath = source.FullPath,

                Schema = source.Schema,
                Table = source.Table,

                Before = before.ToString(),
                After = after.ToString(),
            };
        }
    }
}
