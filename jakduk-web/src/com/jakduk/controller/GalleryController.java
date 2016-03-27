package com.jakduk.controller;

import java.io.IOException;
import java.util.Locale;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.LocaleResolver;

import com.jakduk.common.CommonConst;
import com.jakduk.service.CommonService;
import com.jakduk.service.GalleryService;

/**
 * @author <a href="mailto:phjang1983@daum.net">Jang,Pyohwan</a>
 * @company  : http://jakduk.com
 * @date     : 2015. 1. 18.
 * @desc     :
 */

@Controller
@Slf4j
@RequestMapping("/gallery")
public class GalleryController {
	
	@Autowired
	private GalleryService galleryService;

	@Autowired
	private CommonService commonService;
	
	@Resource
	LocaleResolver localeResolver;

	@RequestMapping
	public String root() {
		
		return "redirect:/gallery/list";
	}
	
	@RequestMapping(value = "/list/refresh", method = RequestMethod.GET)
	public String refreshList() {
		
		return "redirect:/gallery/list";
	}		
	
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String list(Model model,
			HttpServletRequest request) {
		
		Locale locale = localeResolver.resolveLocale(request);
		galleryService.getList(model, locale);
		
		return "gallery/list";
	}
	
	@RequestMapping(value = "/data/list", method = RequestMethod.GET)
	public void dataList(Model model,
			@RequestParam(required = false) String id,
			@RequestParam(required = false, defaultValue = "0") int size) {
		
		galleryService.getDataList(model, id, size);
		
	}
	
	@ResponseBody
	@RequestMapping(value = "/{id}", method = RequestMethod.GET)
	public void gallery(@PathVariable String id, 
			HttpServletResponse response) throws IOException {

		Integer status = galleryService.getImage(response, id);
		
		if (!status.equals(HttpServletResponse.SC_OK)) {
			log.error("image error response = " + status);
			// after the response has been committed 에러가 자꾸 떠서 일단 주석.
			//response.sendError(status);
		}
	}
	
	@ResponseBody
	@RequestMapping(value = "/thumbnail/{id}", method = RequestMethod.GET)
	public void thumbnail(@PathVariable String id,
			HttpServletResponse response) throws IOException {

		Integer status = galleryService.getThumbnail(response, id);
		
		if (!status.equals(HttpServletResponse.SC_OK)) {
			log.error("thumbnail error response = " + status);
			// after the response has been committed 에러가 자꾸 떠서 일단 주석.
			//response.sendError(status);
		}
	}		

	@RequestMapping(value = "/view/{id}", method = RequestMethod.GET)
	public String view(@PathVariable String id, Model model
			, HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		Locale locale = localeResolver.resolveLocale(request);
		Boolean isAddCookie = commonService.addViewsCookie(request, response, CommonConst.COOKIE_NAME_BOARD_FREE, id);
		Integer status = galleryService.getGallery(model, locale, id, isAddCookie);
		
		if (!status.equals(HttpServletResponse.SC_OK)) {
			response.sendError(status);
			return null;
		}
		
		return "gallery/view";		
	}	
	
	@RequestMapping(value = "/{id}/{feeling}")
	public void setGalleryFeeling(@PathVariable String id,
								  @PathVariable CommonConst.FEELING_TYPE feeling,
								  Model model) {
		
		galleryService.setUserFeeling(model, id, feeling);
	}
}
