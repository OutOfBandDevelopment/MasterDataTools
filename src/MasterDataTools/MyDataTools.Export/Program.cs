using CommandLine;
using MyDataTools.Export.Properties;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using static System.Data.ConnectionState;

namespace MyDataTools.Export
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
            await foreach (var t in GetSourcesAsync(options))
            {
                var json = await GetDataAsync(options, t);

                if (!string.IsNullOrWhiteSpace(json))
                {
                    var fileName = Path.Combine(options.OutputPath, string.Format(options.Pattern, t.Schema, t.Table));
                    var directory = Path.GetDirectoryName(fileName);
                    if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);
                    File.WriteAllText(fileName, json);
                }
            }

        }

        private static async Task<string> GetDataAsync(CommandOptions options, TableReference table)
        {
            using var conn = new SqlConnection(options.ConnectionString);
            if (conn.State != Open) await conn.OpenAsync();

            using var cmd = new SqlCommand(table.Script, conn);
            using var reader = await cmd.ExecuteReaderAsync();

            Console.Write($"[{table.Schema}].[{table.Table}]");

            var results = new StringBuilder();
            while (await reader.ReadAsync())
            {
                Console.Write("+");
                results.Append(reader[0] as string);
            }
            Console.WriteLine();

            return results.ToString();
        }

        private static async IAsyncEnumerable<TableReference> GetSourcesAsync(CommandOptions options)
        {
            using var conn = new SqlConnection(options.ConnectionString);
            if (conn.State != Open) await conn.OpenAsync();

            using var cmd = new SqlCommand(Resources.GetTableScripts, conn);
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
                yield return new TableReference
                {
                    Schema = reader[nameof(TableReference.Schema)] as string,
                    Table = reader[nameof(TableReference.Table)] as string,
                    Script = reader["Json" + nameof(TableReference.Script)] as string,
                };
        }
    }
}
