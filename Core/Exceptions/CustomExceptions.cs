using System;

namespace FoundrLink.Core.Exceptions
{
    /// <summary>
    /// Demonstrates Syllabus Unit 3: Exception Handling - Custom Exceptions.
    /// Base custom exception for domain validation errors in FoundrLink.
    /// Inherits from ArgumentException for CTS type compatibility.
    /// </summary>
    public class FoundrLinkValidationException : ArgumentException
    {
        public string PropertyName { get; private set; }

        public FoundrLinkValidationException(string message)
            : base(message)
        {
            PropertyName = string.Empty;
        }

        public FoundrLinkValidationException(string message, string paramName)
            : base(message, paramName)
        {
            PropertyName = paramName;
        }

        public FoundrLinkValidationException(string message, string paramName, Exception innerException)
            : base(message, paramName, innerException)
        {
            PropertyName = paramName;
        }
    }

    /// <summary>
    /// Custom exception thrown when a requested persistent entity cannot be found.
    /// </summary>
    public class EntityNotFoundException : Exception
    {
        public string EntityType { get; private set; }
        public int EntityId { get; private set; }

        public EntityNotFoundException(string entityType, int entityId)
            : base(string.Format("{0} with ID {1} was not found.", entityType, entityId))
        {
            EntityType = entityType;
            EntityId = entityId;
        }
    }

    /// <summary>
    /// Custom exception thrown during user registration when email already exists.
    /// </summary>
    public class DuplicateEmailException : Exception
    {
        public string Email { get; private set; }

        public DuplicateEmailException(string email)
            : base(string.Format("The email address '{0}' is already registered in the system.", email))
        {
            Email = email;
        }
    }
}
