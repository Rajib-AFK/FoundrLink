using System;
using System.Threading;

namespace FoundrLink.Core.Threading
{
    /// <summary>
    /// Demonstrates Syllabus Unit 3: Multithreading.
    /// Concept of threads, creating and managing threads, thread lifecycle
    /// (Unstarted -> Running -> WaitSleepJoin -> Stopped).
    /// </summary>
    public class BackgroundSyncWorker
    {
        private Thread _workerThread;
        private bool _isCompleted;
        private int _itemsProcessed;
        private readonly object _lockObject = new object();

        public bool IsCompleted
        {
            get
            {
                lock (_lockObject)
                {
                    return _isCompleted;
                }
            }
        }

        public int ItemsProcessed
        {
            get
            {
                lock (_lockObject)
                {
                    return _itemsProcessed;
                }
            }
        }

        public ThreadState CurrentThreadState
        {
            get
            {
                if (_workerThread != null)
                {
                    return _workerThread.ThreadState;
                }
                return ThreadState.Unstarted;
            }
        }

        /// <summary>
        /// Creates and starts a new thread using ThreadStart delegate (Unit 3).
        /// </summary>
        public void StartBackgroundAggregation(int itemCount)
        {
            _isCompleted = false;
            _itemsProcessed = 0;

            // Creating a thread explicitly with ThreadStart delegate
            _workerThread = new Thread(new ThreadStart(delegate
            {
                ProcessItems(itemCount);
            }));

            _workerThread.Name = "FoundrLinkSyncWorkerThread";
            _workerThread.IsBackground = true;

            // Thread lifecycle transition: Unstarted -> Running
            _workerThread.Start();
        }

        private void ProcessItems(int count)
        {
            for (int i = 0; i < count; i++)
            {
                // Simulate work with thread sleep
                Thread.Sleep(10);
                lock (_lockObject)
                {
                    _itemsProcessed++;
                }
            }

            lock (_lockObject)
            {
                _isCompleted = true;
            }
        }

        /// <summary>
        /// Manages thread lifecycle by waiting for completion using Thread.Join().
        /// </summary>
        public bool WaitForCompletion(int timeoutMilliseconds)
        {
            if (_workerThread != null && _workerThread.IsAlive)
            {
                return _workerThread.Join(timeoutMilliseconds);
            }
            return true;
        }
    }
}
