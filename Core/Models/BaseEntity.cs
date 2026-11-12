using System;

namespace FoundrLink.Core.Models
{
    /// <summary>
    /// Abstract base entity demonstrating Abstraction and Encapsulation
    /// across all persistent domain entities (Syllabus Unit 2: Classes, Inheritance, Keywords).
    /// </summary>
    public abstract class BaseEntity
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        protected BaseEntity()
        {
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public virtual void Touch()
        {
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
