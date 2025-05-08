namespace todo.Models
{
    using System.Text.Json.Serialization;

    public class Item
    {
        [JsonPropertyName("id")]
        public string Id { get; set; } = string.Empty;

        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        [JsonPropertyName("isComplete")]
        public bool Completed { get; set; }
    }
}
