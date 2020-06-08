using CommandLine;
using MyDataTools.Export.Properties;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
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

            if (results.Length > 0)
            {

                using var stream = new MemoryStream();
                using var textWriter = new StreamWriter(stream);
                await textWriter.WriteAsync(results.ToString());
                stream.Position = 0;
                using var json = await JsonDocument.ParseAsync(stream);
                using var outStream = new MemoryStream();
                using var jsonWriter = new Utf8JsonWriter(outStream, new JsonWriterOptions { Indented = true, });
                json.WriteTo(jsonWriter);
                outStream.Position = 0;
                using var textReader = new StreamReader(outStream);

                var formatted = await textReader.ReadToEndAsync();

                return formatted;
                // return results.ToString();
            }
            else
            {
                return null;
            }
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
