using Microsoft.AspNetCore.Mvc;
using Registration_Management.Models.ViewModels;
using Registration_Management.Repositories;
using Registration_Management.Services;

namespace Registration_Management.Controllers
{
    public class RegistrationController : Controller
    {
        private readonly IRegistrationService _registrationService;
        private readonly IMasterRepository _masterRepo;
        private readonly IWebHostEnvironment _env;
        private readonly IConfiguration _config;

        public RegistrationController(
            IRegistrationService registrationService,
            IMasterRepository masterRepo,
            IWebHostEnvironment env,
            IConfiguration config)
        {
            _registrationService = registrationService;
            _masterRepo = masterRepo;
            _env = env;
            _config = config;
        }

        // -------------------------------------------------------
        // Session guard helper
        // -------------------------------------------------------
        private bool IsAuthenticated => HttpContext.Session.GetString("UserId") != null;

        private IActionResult RedirectToLogin() =>
            RedirectToAction("Login", "Account");

        // -------------------------------------------------------
        // INDEX — Registration List
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> Index(
            int pageNumber = 1, int pageSize = 10,
            string? searchTerm = null,
            string? filterName = null, string? filterUsername = null,
            int? filterStateId = null, string? filterGender = null,
            string? filterFromDate = null, string? filterToDate = null,
            string sortColumn = "CreatedDate", string sortDirection = "DESC")
        {
            if (!IsAuthenticated) return RedirectToLogin();

            DateTime? fromDate = DateTime.TryParse(filterFromDate, out var fd) ? fd : null;
            DateTime? toDate = DateTime.TryParse(filterToDate, out var td) ? td : null;

            var (items, totalCount) = await _registrationService.GetPagedAsync(
                pageNumber, pageSize, searchTerm, filterName, filterUsername,
                filterStateId, filterGender, fromDate, toDate, sortColumn, sortDirection);

            var model = new RegistrationListViewModel
            {
                Registrations = items,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize,
                SearchTerm = searchTerm,
                FilterName = filterName,
                FilterUsername = filterUsername,
                FilterStateId = filterStateId,
                FilterGender = filterGender,
                FilterFromDate = fromDate,
                FilterToDate = toDate,
                SortColumn = sortColumn,
                SortDirection = sortDirection,
                States = await _masterRepo.GetStatesAsync()
            };

            return View(model);
        }

        // -------------------------------------------------------
        // CREATE
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            // Allow create without login (registration page)
            var model = new RegistrationViewModel
            {
                States = await _masterRepo.GetStatesAsync(),
                AllHobbies = await _masterRepo.GetHobbiesAsync()
            };
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(RegistrationViewModel model)
        {
            // Manually validate password fields since [Required] is conditional
            if (string.IsNullOrWhiteSpace(model.Password))
                ModelState.AddModelError("Password", "Password is required.");
            if (string.IsNullOrWhiteSpace(model.ConfirmPassword))
                ModelState.AddModelError("ConfirmPassword", "Confirm Password is required.");

            if (!ModelState.IsValid)
            {
                model.States = await _masterRepo.GetStatesAsync();
                model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                if (model.StateId > 0) model.Cities = await _masterRepo.GetCitiesByStateAsync(model.StateId);
                return View(model);
            }

            try
            {
                var (success, error) = await _registrationService.RegisterAsync(model, _env, _config);
                if (!success)
                {
                    ModelState.AddModelError(string.Empty, error!);
                    model.States = await _masterRepo.GetStatesAsync();
                    model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                    if (model.StateId > 0) model.Cities = await _masterRepo.GetCitiesByStateAsync(model.StateId);
                    return View(model);
                }

                TempData["Success"] = "Registration completed successfully! Please login.";
                return RedirectToAction("Login", "Account");
            }
            catch (Exception)
            {
                ModelState.AddModelError(string.Empty, "An unexpected error occurred. Please try again.");
                model.States = await _masterRepo.GetStatesAsync();
                model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                if (model.StateId > 0) model.Cities = await _masterRepo.GetCitiesByStateAsync(model.StateId);
                return View(model);
            }
        }

        // -------------------------------------------------------
        // DETAILS
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            var model = await _registrationService.GetDetailsAsync(id);
            if (model == null) return NotFound();

            return View(model);
        }

        // -------------------------------------------------------
        // EDIT
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            var model = await _registrationService.GetForEditAsync(id, _masterRepo);
            if (model == null) return NotFound();

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(RegistrationViewModel model)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            // Remove password validation for edit
            ModelState.Remove("Password");
            ModelState.Remove("ConfirmPassword");

            if (!ModelState.IsValid)
            {
                model.States = await _masterRepo.GetStatesAsync();
                model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                if (model.StateId > 0) model.Cities = await _masterRepo.GetCitiesByStateAsync(model.StateId);
                model.ExistingDocuments = (await _registrationService.GetDetailsAsync(model.UserId))?.Documents ?? new();
                return View(model);
            }

            try
            {
                var (success, error) = await _registrationService.UpdateAsync(model, _env, _config);
                if (!success)
                {
                    ModelState.AddModelError(string.Empty, error!);
                    model.States = await _masterRepo.GetStatesAsync();
                    model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                    if (model.StateId > 0) model.Cities = await _masterRepo.GetCitiesByStateAsync(model.StateId);
                    model.ExistingDocuments = (await _registrationService.GetDetailsAsync(model.UserId))?.Documents ?? new();
                    return View(model);
                }

                TempData["Success"] = "Registration updated successfully.";
                return RedirectToAction("Details", new { id = model.UserId });
            }
            catch (Exception)
            {
                ModelState.AddModelError(string.Empty, "An unexpected error occurred. Please try again.");
                model.States = await _masterRepo.GetStatesAsync();
                model.AllHobbies = await _masterRepo.GetHobbiesAsync();
                return View(model);
            }
        }

        // -------------------------------------------------------
        // DELETE
        // -------------------------------------------------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            await _registrationService.DeleteAsync(id);
            TempData["Success"] = "Registration deleted successfully.";
            return RedirectToAction("Index");
        }

        // -------------------------------------------------------
        // AJAX — Username Availability Check
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> CheckUsername(string username, int excludeUserId = 0)
        {
            if (string.IsNullOrWhiteSpace(username))
                return Json(new { available = false, message = "Username is required." });

            var available = await _registrationService.IsUsernameAvailableAsync(username, excludeUserId);
            return Json(new
            {
                available,
                message = available ? "Username is available." : "Username already exists."
            });
        }

        // -------------------------------------------------------
        // AJAX — Cascading Cities
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> GetCities(int stateId)
        {
            var cities = await _masterRepo.GetCitiesByStateAsync(stateId);
            return Json(cities.Select(c => new { c.CityId, c.CityName }));
        }

        // -------------------------------------------------------
        // DOCUMENT — View
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> ViewDocument(int id)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            var doc = await _registrationService.GetDocumentAsync(id);
            if (doc == null) return NotFound();

            var filePath = Path.Combine(_env.WebRootPath, "uploads", doc.StoredFileName);
            if (!System.IO.File.Exists(filePath)) return NotFound();

            var contentType = GetContentType(doc.FileExtension);
            return PhysicalFile(filePath, contentType);
        }

        // -------------------------------------------------------
        // DOCUMENT — Download
        // -------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> DownloadDocument(int id)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            var doc = await _registrationService.GetDocumentAsync(id);
            if (doc == null) return NotFound();

            var filePath = Path.Combine(_env.WebRootPath, "uploads", doc.StoredFileName);
            if (!System.IO.File.Exists(filePath)) return NotFound();

            var contentType = GetContentType(doc.FileExtension);
            return PhysicalFile(filePath, contentType, doc.OriginalFileName);
        }

        // -------------------------------------------------------
        // DOCUMENT — Delete
        // -------------------------------------------------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteDocument(int documentId, int userId)
        {
            if (!IsAuthenticated) return RedirectToLogin();

            await _registrationService.DeleteDocumentAsync(documentId, _env);
            TempData["Success"] = "Document deleted successfully.";
            return RedirectToAction("Details", new { id = userId });
        }

        // -------------------------------------------------------
        // Helper
        // -------------------------------------------------------
        private static string GetContentType(string ext) => ext.ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream"
        };
    }
}
